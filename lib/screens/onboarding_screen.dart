import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
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
  late String _currencySymbol;
  late Locale _locale;
  late bool _breaksEnabled;
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
    _currencySymbol = settings.currencySymbol;
    _locale = settings.locale;
    _breaksEnabled = settings.breaksEnabled;

    for (var e in settings.defaultAutomaticExpenses) {
      _autoAmountControllers.add(
        TextEditingController(text: e.amount.toStringAsFixed(0)),
      );
      _autoDescControllers.add(TextEditingController(text: e.description));
    }
    if (_autoAmountControllers.isEmpty) {
      _autoAmountControllers.add(TextEditingController(text: '20'));
      _autoDescControllers.add(TextEditingController(text: ''));
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
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() async {
    final settings = context.read<SettingsProvider>();
    final l = AppLocalizations.of(context)!;

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
            l.settings_dialog_error_enter_desc,
            isError: true,
          );
          return;
        }
        if (amount == null || amount <= 0) {
          UIUtils.showSnackBar(
            context,
            l.onboarding_auto_expenses_invalid_amount,
            isError: true,
          );
          return;
        }
        expenses.add(AutomaticExpense(description: desc, amount: amount));
      }
    }

    await settings.setBreakDurations(_paidMinutes, _unpaidMinutes);
    await settings.setBreaksEnabled(_breaksEnabled);
    await settings.setShiftRemindersEnabled(_remindersEnabled);
    await settings.setShiftReminderDurationHours(_reminderHours);
    await settings.setAutomaticExpenseEnabled(_autoExpenseEnabled);
    await settings.updateDefaultAutomaticExpenses(expenses);
    await settings.setCurrencySymbol(_currencySymbol);
    await settings.setLocale(_locale);

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
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPage(child: _buildWelcomePage()),
                  _buildPage(child: _buildLanguagePage()),
                  _buildPage(child: _buildReminderSettingsPage()),
                  _buildPage(child: _buildCurrencyPage()),
                  _buildPage(child: _buildAutoExpensePage()),
                  _buildPage(child: _buildBreakSettingsPage()),
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
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EssentialWorkIcon(size: 120, symbol: _currencySymbol),
        const SizedBox(height: 40),
        Text(
          l.onboarding_welcome_title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          l.onboarding_welcome_subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        Text(
          l.onboarding_welcome_description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLanguagePage() {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.language_rounded, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          l.onboarding_language_title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          l.onboarding_language_subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        DropdownButtonFormField<String>(
          initialValue: _locale.languageCode,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            prefixIcon: const Icon(Icons.translate_rounded),
          ),
          items: [
            DropdownMenuItem(value: 'he', child: Text(l.settings_language_he)),
            DropdownMenuItem(value: 'en', child: Text(l.settings_language_en)),
          ],
          onChanged: (val) {
            if (val != null) {
              final newLocale = Locale(val);
              setState(() => _locale = newLocale);
              // Update settings immediately for instant translation
              context.read<SettingsProvider>().setLocale(newLocale);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCurrencyPage() {
    final l = AppLocalizations.of(context)!;
    final currencies = [
      {'value': '₪', 'label': '₪ ILS'},
      {'value': '\$', 'label': '\$ USD'},
      {'value': '€', 'label': '€ EUR'},
      {'value': '£', 'label': '£ GBP'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.payments_outlined, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          l.onboarding_currency_title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          l.onboarding_currency_subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        DropdownButtonFormField<String>(
          initialValue: _currencySymbol,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            prefixIcon: const Icon(Icons.payments_outlined),
          ),
          items: currencies.map((c) {
            return DropdownMenuItem<String>(
              value: c['value'],
              child: Text(c['label']!),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _currencySymbol = val);
              context.read<SettingsProvider>().setCurrencySymbol(val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBreakSettingsPage() {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.timer_outlined, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          l.onboarding_breaks_title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          l.onboarding_breaks_subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l.onboarding_breaks_enable,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          value: _breaksEnabled,
          onChanged: (val) => setState(() => _breaksEnabled = val),
          activeThumbColor: AppTheme.primaryDark,
          activeTrackColor: AppTheme.primary.withValues(alpha: 0.35),
        ),
        if (_breaksEnabled) ...[
          const SizedBox(height: 32),
          _buildDurationSlider(
            label: l.onboarding_breaks_paid_label,
            value: _paidMinutes,
            onChanged: (val) => setState(() => _paidMinutes = val),
          ),
          const SizedBox(height: 32),
          _buildDurationSlider(
            label: l.onboarding_breaks_unpaid_label,
            value: _unpaidMinutes,
            onChanged: (val) => setState(() => _unpaidMinutes = val),
          ),
        ],
      ],
    );
  }

  Widget _buildReminderSettingsPage() {
    final l = AppLocalizations.of(context)!;
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
        Text(
          l.onboarding_reminders_title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          l.onboarding_reminders_subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l.onboarding_reminders_enable,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          value: _remindersEnabled,
          onChanged: (val) => setState(() => _remindersEnabled = val),
          activeThumbColor: AppTheme.primaryDark,
          activeTrackColor: AppTheme.primary.withValues(alpha: 0.35),
        ),
        if (_remindersEnabled) ...[
          const SizedBox(height: 32),
          _buildDurationSlider(
            label: l.onboarding_reminders_time_label,
            value: _reminderHours,
            min: 0.5,
            max: 24,
            divisions: 47,
            displaySuffix: l.onboarding_reminders_hours,
            onChanged: (val) => setState(() => _reminderHours = val),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoExpensePage() {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.auto_fix_high_rounded, size: 64, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          l.onboarding_auto_expenses_title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          l.onboarding_auto_expenses_subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 40),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            l.onboarding_auto_expenses_enable,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            (index) => _buildAutoExpenseRow(index, _currencySymbol),
          ),
          TextButton.icon(
            onPressed: () => setState(() {
              _autoAmountControllers.add(TextEditingController(text: '0'));
              _autoDescControllers.add(TextEditingController(text: ''));
            }),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(l.onboarding_auto_expenses_add_button),
          ),
        ],
      ],
    );
  }

  Widget _buildAutoExpenseRow(int index, String symbol) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _autoDescControllers[index],
              decoration: InputDecoration(
                labelText: l.onboarding_auto_expenses_desc_label,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: TextField(
              controller: _autoAmountControllers[index],
              decoration: InputDecoration(labelText: symbol),
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
    String displaySuffix = '',
  }) {
    if (displaySuffix.isEmpty) {
      displaySuffix = AppLocalizations.of(context)!.common_min_suffix;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    final jobTypes = shiftProvider.jobTypes;
    final l = AppLocalizations.of(context)!;

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
              Text(
                l.onboarding_job_types_title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.onboarding_job_types_subtitle,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                      label: Text(l.onboarding_job_types_add_button),
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
                    '${UIUtils.formatCurrency(job.getRateForDate(DateTime.now()), symbol: symbol)} ${l.onboarding_job_types_rate_suffix}',
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
                          final provider = context.read<ShiftProvider>();
                          final confirmed = await UIUtils.showConfirmDialog(
                            context: context,
                            title: l.onboarding_job_types_delete_title,
                            content:
                                '${l.onboarding_job_types_delete_desc} ${job.name}?',
                            isDestructive: true,
                            confirmLabel: l.common_delete,
                            cancelLabel: l.common_cancel,
                          );
                          if (confirmed == true && context.mounted) {
                            provider.deleteJobType(job.id);
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
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: job.name);
    final rateController = TextEditingController(
      text: job.getRateForDate(DateTime.now()).toString(),
    );
    DateTime effectiveDate = DateTime.now();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.onboarding_job_types_edit_button),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l.onboarding_auto_expenses_desc_label,
                ),
              ),
              TextField(
                controller: rateController,
                decoration: InputDecoration(
                  labelText: l.onboarding_auto_expenses_amount_label,
                ),
                keyboardType: TextInputType.number,
              ),
              ListTile(
                title: Text(l.common_back),
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
              child: Text(l.common_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final rate =
                    double.tryParse(rateController.text) ?? job.hourlyRate;
                if (name.isEmpty) return;
                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: l.onboarding_job_types_edit_button,
                  content: '${l.onboarding_job_types_edit_button} $name?',
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
              child: Text(l.common_save),
            ),
          ],
        ),
      ),
    );
  }

  void _addNewJobType() {
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.onboarding_job_types_add_button),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l.onboarding_auto_expenses_desc_label,
              ),
            ),
            TextField(
              controller: rateController,
              decoration: InputDecoration(
                labelText: l.onboarding_auto_expenses_amount_label,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.common_cancel),
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
            child: Text(l.common_confirm),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _currentPage > 0
                  ? TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                      ),
                      label: Text(
                        l.common_back,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                7,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 10 : 8,
                  height: _currentPage == index ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  _currentPage == 6 ? l.common_start : l.common_continue,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
