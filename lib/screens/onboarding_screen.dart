import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/wage_entry.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/home_screen.dart';
import 'package:shiftly/services/notification_service.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:shiftly/widgets/app_icon.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // State
  late double _paidMinutes;
  late double _unpaidMinutes;
  late bool _remindersEnabled;
  late double _reminderHours;
  late bool _autoExpenseEnabled;
  final List<TextEditingController> _autoAmountControllers = [];
  final List<TextEditingController> _autoDescControllers = [];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _paidMinutes = settings.paidBreakDurationMinutes;
    _unpaidMinutes = settings.unpaidBreakDurationMinutes;
    _remindersEnabled = settings.shiftRemindersEnabled;
    _reminderHours = settings.shiftReminderDurationHours;
    _autoExpenseEnabled = settings.automaticExpenseEnabled;

    for (var e in settings.defaultAutomaticExpenses) {
      _autoAmountControllers.add(
        TextEditingController(text: e.amount.toStringAsFixed(0)),
      );
      _autoDescControllers.add(TextEditingController(text: e.description));
    }
    if (_autoAmountControllers.isEmpty) {
      _autoAmountControllers.add(TextEditingController(text: '20'));
      _autoDescControllers.add(TextEditingController(text: 'נסיעות'));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var c in _autoAmountControllers) {
      c.dispose();
    }
    for (var c in _autoDescControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final settings = context.read<SettingsProvider>();

    List<AutomaticExpense> expenses = [];
    if (_autoExpenseEnabled) {
      for (int i = 0; i < _autoAmountControllers.length; i++) {
        final amountText = _autoAmountControllers[i].text.trim();
        final desc = _autoDescControllers[i].text.trim();

        if (amountText.isEmpty && desc.isEmpty) continue;

        final amount = double.tryParse(amountText);
        if (desc.isEmpty) {
          UIUtils.showSnackBar(
            context,
            'נא להזין תיאור לכל ההוצאות הקבועות',
            isError: true,
          );
          return;
        }
        if (amount == null || amount <= 0) {
          UIUtils.showSnackBar(
            context,
            'סכום ההוצאה "$desc" חייב להיות מספר גדול מ-0',
            isError: true,
          );
          return;
        }
        expenses.add(AutomaticExpense(description: desc, amount: amount));
      }
    }

    await settings.setBreakDurations(_paidMinutes, _unpaidMinutes);
    await settings.setShiftRemindersEnabled(_remindersEnabled);
    await settings.setShiftReminderDurationHours(_reminderHours);
    await settings.setAutomaticExpenseEnabled(_autoExpenseEnabled);
    await settings.updateDefaultAutomaticExpenses(expenses);

    if (_remindersEnabled) {
      await NotificationService.requestPermissions();
    }

    await settings.completeOnboarding();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPage(child: _buildWelcomePage()),
                  _buildPage(child: _buildBreakSettingsPage()),
                  _buildPage(child: _buildReminderSettingsPage()),
                  _buildPage(child: _buildAutoExpensePage()),
                  _buildJobTypesPage(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required Widget child}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: child,
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const EssentialWorkIcon(size: 120),
        const SizedBox(height: 40),
        const Text(
          'ברוכים הבאים ל-Shiftly',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'האפליקציה שתעזור לך לעקוב אחרי המשמרות, השכר והטיפים שלך בקלות ובדיוק.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'בוא נגדיר כמה דברים בסיסיים כדי להתחיל.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Arial',
          ),
        ),
      ],
    );
  }

  Widget _buildBreakSettingsPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.timer_outlined, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'הגדרות הפסקה',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'כמה זמן נמשכת הפסקה בדרך כלל?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 40),
        _buildDurationSlider(
          label: 'הפסקה בתשלום (דקות)',
          value: _paidMinutes,
          onChanged: (val) => setState(() => _paidMinutes = val),
        ),
        const SizedBox(height: 32),
        _buildDurationSlider(
          label: 'הפסקה ללא תשלום (דקות)',
          value: _unpaidMinutes,
          onChanged: (val) => setState(() => _unpaidMinutes = val),
        ),
      ],
    );
  }

  Widget _buildReminderSettingsPage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.notifications_active_outlined,
          size: 64,
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        const Text(
          'תזכורות למשמרת',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'האם תרצה לקבל תזכורת לפני שהמשמרת מתחילה?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 40),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'הפעל תזכורות',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          value: _remindersEnabled,
          onChanged: (val) => setState(() => _remindersEnabled = val),
          activeThumbColor: AppTheme.primaryDark,
          activeTrackColor: AppTheme.primary.withValues(alpha: 0.35),
        ),
        if (_remindersEnabled) ...[
          const SizedBox(height: 32),
          _buildDurationSlider(
            label: 'כמה זמן לפני? (שעות)',
            value: _reminderHours,
            min: 0.5,
            max: 24,
            divisions: 47,
            displaySuffix: 'שעות',
            onChanged: (val) => setState(() => _reminderHours = val),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoExpensePage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.auto_fix_high_rounded, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          'הוצאות קבועות',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'האם יש לך הוצאות קבועות בכל משמרת? (למשל נסיעות)',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 40),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'הפעל הוצאות אוטומטיות',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          value: _autoExpenseEnabled,
          onChanged: (val) => setState(() => _autoExpenseEnabled = val),
          activeThumbColor: AppTheme.primaryDark,
          activeTrackColor: AppTheme.primary.withValues(alpha: 0.35),
        ),
        if (_autoExpenseEnabled) ...[
          const SizedBox(height: 24),
          ...List.generate(
            _autoAmountControllers.length,
            (index) => _buildAutoExpenseRow(index),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _autoAmountControllers.add(TextEditingController(text: '0'));
              _autoDescControllers.add(TextEditingController(text: ''));
            }),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('הוסף הוצאה'),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoExpenseRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _autoDescControllers[index],
              decoration: const InputDecoration(labelText: 'תיאור'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _autoAmountControllers[index],
              decoration: const InputDecoration(labelText: '₪'),
              keyboardType: TextInputType.number,
            ),
          ),
          if (_autoAmountControllers.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => setState(() {
                _autoAmountControllers.removeAt(index);
                _autoDescControllers.removeAt(index);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildDurationSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0,
    double max = 120,
    int divisions = 24,
    String displaySuffix = 'דק\'',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
            ),
            Text(
              '${(value * 10).round() / 10} $displaySuffix'.replaceAll(
                '.0 ',
                ' ',
              ),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildJobTypesPage() {
    final shiftProvider = context.watch<ShiftProvider>();
    final jobTypes = shiftProvider.jobTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.work_outline, size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'סוגי משמרות ושכר',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'הגדר את התפקידים השונים שלך ואת השכר לשעה.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            itemCount: jobTypes.length + 1,
            itemBuilder: (context, index) {
              if (index == jobTypes.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: _addNewJobType,
                      icon: const Icon(Icons.add),
                      label: const Text('הוסף סוג משמרת'),
                    ),
                  ),
                );
              }
              final job = jobTypes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    job.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${UIUtils.formatCurrency(job.getRateForDate(DateTime.now()))} לשעה',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editJobType(job),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          final confirmed = await UIUtils.showConfirmDialog(
                            context: context,
                            title: 'מחיקת תפקיד',
                            content: 'האם למחוק את התפקיד "${job.name}"?',
                            isDestructive: true,
                            confirmLabel: 'מחק',
                          );
                          if (confirmed == true && context.mounted) {
                            context.read<ShiftProvider>().deleteJobType(job.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _editJobType(JobType job) {
    final nameController = TextEditingController(text: job.name);
    final rateController = TextEditingController(
      text: job.getRateForDate(DateTime.now()).toString(),
    );
    DateTime effectiveDate = DateTime.now();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ערוך סוג משמרת'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'שם התפקיד'),
              ),
              TextField(
                controller: rateController,
                decoration: const InputDecoration(labelText: 'שכר לשעה'),
                keyboardType: TextInputType.number,
              ),
              ListTile(
                title: const Text('תאריך תחילה'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(effectiveDate)),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: effectiveDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => effectiveDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final rate =
                    double.tryParse(rateController.text) ?? job.hourlyRate;
                if (name.isEmpty) return;
                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: 'עדכון תפקיד',
                  content:
                      'האם לעדכן את "$name" החל מיום ${DateFormat('dd/MM/yyyy').format(effectiveDate)}?',
                );
                if (confirmed != true || !context.mounted) return;
                final history = List<WageEntry>.from(job.wageHistory ?? [])
                  ..removeWhere((e) => isSameDay(e.startDate, effectiveDate))
                  ..add(WageEntry(startDate: effectiveDate, hourlyRate: rate))
                  ..sort((a, b) => a.startDate.compareTo(b.startDate));
                final updated = job.copyWith(name: name, wageHistory: history)
                  ..syncCurrentRate();
                await context.read<ShiftProvider>().updateJobType(updated);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewJobType() {
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('סוג משמרת חדש'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'שם התפקיד'),
            ),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(labelText: 'שכר לשעה'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ביטול'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final rate = double.tryParse(rateController.text) ?? 0.0;
              if (name.isEmpty) return;
              final newJob = JobType(
                id: const Uuid().v4(),
                name: name,
                hourlyRate: rate,
                wageHistory: [
                  WageEntry(startDate: DateTime.now(), hourlyRate: rate),
                ],
              )..syncCurrentRate();
              context.read<ShiftProvider>().addJobType(newJob);
              Navigator.pop(context);
            },
            child: const Text('הוסף'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.blue
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            child: Text(_currentPage == 4 ? 'בוא נתחיל!' : 'המשך'),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
