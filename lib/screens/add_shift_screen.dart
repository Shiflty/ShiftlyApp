import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/providers/timer_provider.dart';
import 'package:shiftly/services/shift_parser.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:uuid/uuid.dart';

class AddShiftScreen extends StatefulWidget {
  final Shift? shiftToEdit;
  final int initialTabIndex;

  const AddShiftScreen({super.key, this.shiftToEdit, this.initialTabIndex = 0});

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;

  // Manual Form State
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String? _selectedJobTypeId;
  final List<TextEditingController> _tipControllers = [];
  late BreakType _selectedBreakType;

  // Raw Paste State
  final TextEditingController _rawTextController = TextEditingController();

  // Timer State
  final List<TextEditingController> _timerTipControllers = [];
  final List<TextEditingController> _autoExpenseAmountControllers = [];
  final List<TextEditingController> _autoExpenseDescControllers = [];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();

    _tabController = TabController(
      length: widget.shiftToEdit == null ? 3 : 1,
      vsync: this,
      initialIndex: widget.shiftToEdit == null ? widget.initialTabIndex : 0,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    if (widget.shiftToEdit != null) {
      final s = widget.shiftToEdit!;
      _selectedDate = s.date;
      _startTime = TimeOfDay.fromDateTime(s.startTime);
      _endTime = TimeOfDay.fromDateTime(s.endTime);
      _selectedJobTypeId = s.jobTypeId;
      _selectedBreakType = s.breakType ?? BreakType.none;

      final expenses = s.automaticExpenses ?? [];
      for (var e in expenses) {
        _autoExpenseAmountControllers.add(
          TextEditingController(text: e.amount.toStringAsFixed(0)),
        );
        _autoExpenseDescControllers.add(
          TextEditingController(text: e.description),
        );
      }

      if (s.individualTips != null && s.individualTips!.isNotEmpty) {
        for (var tip in s.individualTips!) {
          _tipControllers.add(
            TextEditingController(text: tip.toStringAsFixed(0)),
          );
        }
      } else if (s.tips > 0) {
        _tipControllers.add(
          TextEditingController(text: s.tips.toStringAsFixed(0)),
        );
      } else {
        _tipControllers.add(TextEditingController(text: '0'));
      }
    } else {
      _tipControllers.add(TextEditingController(text: '0'));
      _timerTipControllers.add(TextEditingController(text: '0'));

      if (settings.automaticExpenseEnabled) {
        for (var e in settings.defaultAutomaticExpenses) {
          _autoExpenseAmountControllers.add(
            TextEditingController(text: e.amount.toStringAsFixed(0)),
          );
          _autoExpenseDescControllers.add(
            TextEditingController(text: e.description),
          );
        }
      }

      final timer = context.read<TimerProvider>();
      final isFromTimerReview = timer.startTime != null && !timer.isRunning;

      if (isFromTimerReview) {
        _selectedDate = timer.startTime!;
        _startTime = TimeOfDay.fromDateTime(timer.startTime!);
        _endTime = TimeOfDay.fromDateTime(
          timer.reviewEndTime ?? DateTime.now(),
        );
        _selectedJobTypeId = timer.jobTypeId;
        _selectedBreakType = timer.accumulatedUnpaidMinutes > 0
            ? BreakType.unpaid
            : BreakType.none;

        _tipControllers.clear();
        _tipControllers.add(
          TextEditingController(text: timer.tips.toStringAsFixed(0)),
        );
        _timerTipControllers.clear();
        _timerTipControllers.add(
          TextEditingController(text: timer.tips.toStringAsFixed(0)),
        );
      } else {
        _selectedDate = DateTime.now();
        _startTime = const TimeOfDay(hour: 9, minute: 0);
        _endTime = const TimeOfDay(hour: 17, minute: 0);
        _selectedBreakType = BreakType.none;

        final jobs = context.read<ShiftProvider>().jobTypes;
        if (jobs.isNotEmpty) {
          final buffet = jobs.firstWhere(
            (j) => j.id == '1',
            orElse: () => jobs.first,
          );
          _selectedJobTypeId = buffet.id;
        }

        if (timer.isRunning) {
          _selectedJobTypeId = timer.jobTypeId ?? _selectedJobTypeId;
          _timerTipControllers.clear();
          _timerTipControllers.add(
            TextEditingController(text: timer.tips.toStringAsFixed(0)),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    for (var c in _tipControllers) {
      c.dispose();
    }
    for (var c in _timerTipControllers) {
      c.dispose();
    }
    for (var c in _autoExpenseAmountControllers) {
      c.dispose();
    }
    for (var c in _autoExpenseDescControllers) {
      c.dispose();
    }
    _rawTextController.dispose();
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateTotalTips(List<TextEditingController> controllers) {
    return controllers.fold(
      0.0,
      (sum, c) => sum + (double.tryParse(c.text) ?? 0.0),
    );
  }

  List<double> _getTipList(List<TextEditingController> controllers) {
    return controllers
        .map((c) => double.tryParse(c.text) ?? 0.0)
        .where((t) => t > 0)
        .toList();
  }

  List<AutomaticExpense>? _getExpenseList() {
    final l = AppLocalizations.of(context)!;
    List<AutomaticExpense> list = [];
    for (int i = 0; i < _autoExpenseAmountControllers.length; i++) {
      final amountText = _autoExpenseAmountControllers[i].text.trim();
      final desc = _autoExpenseDescControllers[i].text.trim();

      if (amountText.isEmpty && desc.isEmpty) continue;

      final amount = double.tryParse(amountText);
      if (desc.isEmpty) {
        UIUtils.showSnackBar(
          context,
          l.settings_dialog_error_enter_desc,
          isError: true,
        );
        return null;
      }
      if (amount == null || amount < 0) {
        UIUtils.showSnackBar(context, l.common_error, isError: true);
        return null;
      }
      if (amount > 0) {
        list.add(AutomaticExpense(description: desc, amount: amount));
      }
    }
    return list;
  }

  void _finishTimerShift() async {
    final timerProvider = context.read<TimerProvider>();
    final shiftProvider = context.read<ShiftProvider>();
    final l = AppLocalizations.of(context)!;

    if (timerProvider.startTime == null || timerProvider.jobTypeId == null) {
      return;
    }

    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.common_confirm,
      content: l.common_confirm,
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final end = timerProvider.isRunning
        ? DateTime.now()
        : (timerProvider.reviewEndTime ?? DateTime.now());

    final expenses = _getExpenseList();
    if (expenses == null) return;

    final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");

    final shift = Shift(
      id: const Uuid().v4(),
      date: timerProvider.startTime!,
      startTime: timerProvider.startTime!,
      endTime: end,
      jobTypeId: timerProvider.jobTypeId!,
      tips: _calculateTotalTips(_timerTipControllers),
      individualTips: _getTipList(_timerTipControllers),
      hourlyRate: job?.getRateForDate(timerProvider.startTime!),
      automaticExpenses: expenses,
      breakType: timerProvider.accumulatedUnpaidMinutes > 0
          ? BreakType.unpaid
          : BreakType.none,
      unpaidBreakMinutes: timerProvider.accumulatedUnpaidMinutes,
    );

    shiftProvider.addShift(
      shift,
      l10n: {
        'title': l.notification_reminder_title,
        'body': l.notification_reminder_body,
        'hours': l.common_hours_suffix,
        'minutes': l.common_min_suffix,
        'channelName': l.notification_channel_reminders_name,
        'channelDesc': l.notification_channel_reminders_desc,
      },
    );
    timerProvider.resetTimer();

    if (!mounted) return;
    UIUtils.showSnackBar(context, l.common_success);
    Navigator.pop(context);
  }

  void _saveManual() async {
    if (_selectedJobTypeId == null) return;
    final l = AppLocalizations.of(context)!;

    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    var end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: widget.shiftToEdit != null ? l.common_save : l.common_confirm,
      content: l.common_confirm,
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final shiftProvider = context.read<ShiftProvider>();
    final settings = context.read<SettingsProvider>();
    final job = shiftProvider.getJobTypeById(_selectedJobTypeId!);

    final expenses = _getExpenseList();
    if (expenses == null) return;

    if (widget.shiftToEdit != null) {
      final s = widget.shiftToEdit!;
      s.date = _selectedDate;
      s.startTime = start;
      s.endTime = end;
      s.jobTypeId = _selectedJobTypeId!;
      s.tips = _calculateTotalTips(_tipControllers);
      s.individualTips = _getTipList(_tipControllers);
      s.hourlyRate = job?.getRateForDate(_selectedDate);
      s.automaticExpenses = expenses;
      s.breakType = _selectedBreakType;
      s.unpaidBreakMinutes = settings.unpaidBreakDurationMinutes;

      if (!mounted) return;
      shiftProvider.updateShift(
        s,
        l10n: {
          'title': l.notification_reminder_title,
          'body': l.notification_reminder_body,
          'hours': l.common_hours_suffix,
          'minutes': l.common_min_suffix,
          'channelName': l.notification_channel_reminders_name,
          'channelDesc': l.notification_channel_reminders_desc,
        },
      );

      UIUtils.showSnackBar(context, l.common_success);
    } else {
      final shift = Shift(
        id: const Uuid().v4(),
        date: _selectedDate,
        startTime: start,
        endTime: end,
        jobTypeId: _selectedJobTypeId!,
        tips: _calculateTotalTips(_tipControllers),
        individualTips: _getTipList(_tipControllers),
        hourlyRate: job?.getRateForDate(_selectedDate),
        automaticExpenses: expenses,
        breakType: _selectedBreakType,
        unpaidBreakMinutes: settings.unpaidBreakDurationMinutes,
      );
      if (!mounted) return;
      shiftProvider.addShift(
        shift,
        l10n: {
          'title': l.notification_reminder_title,
          'body': l.notification_reminder_body,
          'hours': l.common_hours_suffix,
          'minutes': l.common_min_suffix,
          'channelName': l.notification_channel_reminders_name,
          'channelDesc': l.notification_channel_reminders_desc,
        },
      );

      UIUtils.showSnackBar(context, l.common_success);
    }
    if (mounted) Navigator.pop(context);
  }

  void _saveRaw() async {
    if (_selectedJobTypeId == null) return;
    final settings = context.read<SettingsProvider>();
    final l = AppLocalizations.of(context)!;

    final lines = _rawTextController.text.split('\n');
    final validLines = lines.where((l) => l.trim().isNotEmpty).toList();
    if (validLines.isEmpty) return;

    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.common_confirm,
      content: '${l.common_confirm} ${validLines.length}?',
    );
    if (confirmed != true) return;
    if (!mounted) return;

    final shiftProvider = context.read<ShiftProvider>();
    final job = shiftProvider.getJobTypeById(_selectedJobTypeId!);

    int addedCount = 0;
    for (var line in validLines) {
      final shift = ShiftParser.parse(
        line,
        _selectedJobTypeId!,
        paidMinutes: settings.paidBreakDurationMinutes,
        unpaidMinutes: settings.unpaidBreakDurationMinutes,
      );
      if (shift != null) {
        shift.hourlyRate = job?.getRateForDate(shift.date);
        if (settings.automaticExpenseEnabled) {
          shift.automaticExpenses = settings.defaultAutomaticExpenses
              .map((e) => e.copyWith())
              .toList();
        }
        if (!mounted) continue;
        shiftProvider.addShift(
          shift,
          l10n: {
            'title': l.notification_reminder_title,
            'body': l.notification_reminder_body,
            'hours': l.common_hours_suffix,
            'minutes': l.common_min_suffix,
            'channelName': l.notification_channel_reminders_name,
            'channelDesc': l.notification_channel_reminders_desc,
          },
        );
        addedCount++;
      }
    }

    if (!mounted) return;
    if (addedCount > 0) {
      Navigator.pop(context);
    } else {
      UIUtils.showSnackBar(context, l.common_error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawJobs = context.watch<ShiftProvider>().jobTypes;
    final l = AppLocalizations.of(context)!;

    final jobs = List<JobType>.from(rawJobs)
      ..sort((a, b) {
        if (a.id == '1') return -1;
        if (b.id == '1') return 1;
        if (a.id == '2') return -1;
        if (b.id == '2') return 1;
        return a.name.compareTo(b.name);
      });

    final isEditing = widget.shiftToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l.add_shift_edit_title : l.add_shift_title),
        bottom: isEditing
            ? null
            : TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    text: l.add_shift_timer_tab,
                    icon: const Icon(Icons.timer_outlined),
                  ),
                  Tab(
                    text: l.add_shift_manual_tab,
                    icon: const Icon(Icons.edit_note_rounded),
                  ),
                  Tab(
                    text: l.add_shift_paste_tab,
                    icon: const Icon(Icons.paste_rounded),
                  ),
                ],
              ),
      ),
      body: SafeArea(
        child: isEditing
            ? _buildManualForm(jobs)
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTimerForm(jobs),
                  _buildManualForm(jobs),
                  _buildRawForm(jobs),
                ],
              ),
      ),
    );
  }

  Widget _buildTimerForm(List<JobType> jobs) {
    final timerProvider = context.watch<TimerProvider>();
    final shiftProvider = context.watch<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
    final isRunning = timerProvider.isRunning;
    final isOnBreak = timerProvider.isOnBreak;
    final isReviewMode = timerProvider.startTime != null && !isRunning;
    final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
    final livePay = timerProvider.calculateLivePay(
      job?.getRateForDate(timerProvider.startTime ?? DateTime.now()) ?? 40.22,
    );

    String formatDuration(Duration d) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      return "${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
    }

    final buttonColor = isReviewMode
        ? AppTheme.profit
        : (isRunning
              ? (isOnBreak ? AppTheme.warningSoft : AppTheme.primary)
              : Theme.of(context).colorScheme.surfaceContainerHighest);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        120, // Bottom space for ads and system navigation
      ),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.spaceSm),
          // Pulsating circular start/stop
          ScalePress(
            onTap: () {
              if (isReviewMode) {
                timerProvider.resumeShift();
                _tabController.animateTo(0);
              } else if (!isRunning) {
                if (_selectedJobTypeId == null) {
                  UIUtils.showSnackBar(context, l.common_error, isError: true);
                  return;
                }
                timerProvider.startShift(_selectedJobTypeId!);
                for (var c in _timerTipControllers) {
                  c.text = '0';
                }
              } else {
                if (isOnBreak) {
                  timerProvider.endBreak();
                } else {
                  _showFinishDialog();
                }
              }
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final pulse = isRunning && !isOnBreak
                    ? 8 + (_pulseController.value * 14)
                    : 6.0;
                final glowAlpha = isRunning && !isOnBreak
                    ? 0.25 + (_pulseController.value * 0.25)
                    : 0.2;
                return Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withValues(alpha: glowAlpha),
                        blurRadius: pulse,
                        spreadRadius: isRunning && !isOnBreak
                            ? 4 + (_pulseController.value * 8)
                            : 2,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: buttonColor,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isReviewMode
                            ? Icons.play_arrow_rounded
                            : (isRunning
                                  ? (isOnBreak
                                        ? Icons.play_arrow_rounded
                                        : Icons.stop_rounded)
                                  : Icons.play_arrow_rounded),
                        size: 64,
                        color: isReviewMode || isRunning
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        isReviewMode
                            ? l.common_continue
                            : (isRunning
                                  ? (isOnBreak
                                        ? l.add_shift_timer_resume_work
                                        : l.add_shift_timer_stop_shift)
                                  : l.add_shift_timer_start_shift),
                        style: TextStyle(
                          color: isReviewMode || isRunning
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            formatDuration(timerProvider.elapsed),
            style: AppTheme.monoNumber.copyWith(
              fontSize: 48,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            UIUtils.formatCurrency(livePay, symbol: symbol),
            style: AppTheme.monoNumber.copyWith(
              fontSize: 28,
              color: livePay < 0 ? AppTheme.expense : AppTheme.primaryDark,
            ),
          ),
          Text(
            l.add_shift_timer_accumulated_live,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (isOnBreak || timerProvider.accumulatedUnpaidMinutes > 0) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSm,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  if (isOnBreak)
                    Text(
                      '${l.add_shift_timer_countdown} ${timerProvider.breakRemaining.inMinutes}:${(timerProvider.breakRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: AppTheme.monoNumber.copyWith(
                        fontSize: 20,
                        color: timerProvider.activeBreakType == BreakType.paid
                            ? AppTheme.primaryDark
                            : AppTheme.warningSoft,
                      ),
                    ),
                  Text(
                    isOnBreak
                        ? (timerProvider.activeBreakType == BreakType.paid
                              ? l.add_shift_timer_break_paid
                              : l.add_shift_timer_break_unpaid)
                        : '${l.add_shift_timer_total_break_unpaid} ${timerProvider.accumulatedUnpaidMinutes.toStringAsFixed(1)} ${l.common_min_suffix}',
                    style: TextStyle(
                      color: AppTheme.warningSoft,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spaceLg),

          // Controls section
          _FormSection(
            title: l.add_shift_manual_work_tips_section,
            icon: Icons.work_outline_rounded,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: (isRunning || isReviewMode)
                      ? timerProvider.jobTypeId
                      : _selectedJobTypeId,
                  decoration: InputDecoration(
                    labelText: l.add_shift_manual_job_type_label,
                    prefixIcon: const Icon(Icons.work_rounded),
                  ),
                  items: jobs
                      .map(
                        (j) => DropdownMenuItem(
                          value: j.id,
                          child: Row(
                            children: [
                              Icon(AppTheme.iconForJobName(j.name), size: 18),
                              const SizedBox(width: 8),
                              Text(j.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    if (isRunning || isReviewMode) {
                      timerProvider.setJobType(val);
                    } else {
                      setState(() => _selectedJobTypeId = val);
                    }
                  },
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildTipsSection(_timerTipControllers, symbol),
                const SizedBox(height: AppTheme.spaceMd),
                _buildAutoExpensesSection(symbol),
              ],
            ),
          ),

          if (settings.breaksEnabled) ...[
            if (isRunning && !isReviewMode) ...[
              const SizedBox(height: AppTheme.spaceMd),
              _FormSection(
                title: l.add_shift_manual_break_type_section,
                icon: Icons.coffee_outlined,
                child: SegmentedButton<BreakType?>(
                  emptySelectionAllowed: true,
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: BreakType.paid,
                      icon: const Icon(Icons.timer_outlined, size: 18),
                      label: Text(
                        '${context.read<SettingsProvider>().paidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_paid_break}',
                      ),
                    ),
                    ButtonSegment(
                      value: BreakType.unpaid,
                      icon: const Icon(Icons.coffee_outlined, size: 18),
                      label: Text(
                        '${context.read<SettingsProvider>().unpaidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_unpaid_break}',
                      ),
                    ),
                  ],
                  selected: {if (isOnBreak) timerProvider.activeBreakType},
                  onSelectionChanged: (val) {
                    final settings = context.read<SettingsProvider>();
                    if (val.isEmpty) {
                      if (isOnBreak) timerProvider.endBreak();
                      return;
                    }
                    final type = val.first!;
                    final minutes = type == BreakType.paid
                        ? settings.paidBreakDurationMinutes
                        : settings.unpaidBreakDurationMinutes;
                    timerProvider.toggleBreak(type, minutes);
                  },
                ),
              ),
            ],
          ],

          const SizedBox(height: AppTheme.spaceMd),
          if (isRunning || isReviewMode)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isReviewMode ? _finishTimerShift : _showFinishDialog,
                icon: Icon(
                  isReviewMode ? Icons.check_rounded : Icons.stop_rounded,
                ),
                label: Text(
                  isReviewMode ? l.common_save : l.add_shift_timer_stop_shift,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReviewMode
                      ? AppTheme.profit
                      : AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          if (isRunning || isReviewMode)
            TextButton(
              onPressed: () async {
                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: l.common_confirm,
                  content: l.common_confirm,
                  isDestructive: true,
                  confirmLabel: l.common_back,
                );
                if (confirmed != true) return;
                if (!mounted) return;
                timerProvider.resetTimer();
              },
              child: Text(
                l.common_back,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFinishDialog() {
    context.read<TimerProvider>().stopShift();
    final l = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l.add_shift_timer_stop_shift),
        content: Text(l.add_shift_timer_stopped_msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TimerProvider>().resumeShift();
            },
            child: Text(l.add_shift_timer_continue_work),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _finishTimerShift();
            },
            child: Text(l.common_save),
          ),
        ],
      ),
    );
  }

  Widget _buildManualForm(List<JobType> jobs) {
    final settings = context.read<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        120, // Bottom space for ads and system navigation
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormSection(
            title: l.add_shift_manual_time_section,
            icon: Icons.schedule_rounded,
            child: Column(
              children: [
                _PickerTile(
                  icon: Icons.calendar_month_rounded,
                  title: l.add_shift_manual_date_label,
                  value: DateFormat('dd/MM/yyyy').format(_selectedDate),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && mounted) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
                const Divider(height: 1),
                _PickerTile(
                  icon: Icons.access_time_rounded,
                  title: l.add_shift_manual_start_time_label,
                  value: _startTime.format(context),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                    );
                    if (picked != null && mounted) {
                      setState(() => _startTime = picked);
                    }
                  },
                ),
                const Divider(height: 1),
                _PickerTile(
                  icon: Icons.access_time_filled_rounded,
                  title: l.add_shift_manual_end_time_label,
                  value: _endTime.format(context),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                    );
                    if (picked != null && mounted) {
                      setState(() => _endTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          if (settings.breaksEnabled) ...[
            const SizedBox(height: AppTheme.spaceSm),
            _FormSection(
              title: l.add_shift_manual_break_type_section,
              icon: Icons.coffee_outlined,
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<BreakType>(
                  segments: [
                    ButtonSegment(
                      value: BreakType.none,
                      label: Text(l.add_shift_manual_no_break),
                    ),
                    ButtonSegment(
                      value: BreakType.paid,
                      label: Text(
                        '${settings.paidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_paid_break}',
                      ),
                    ),
                    ButtonSegment(
                      value: BreakType.unpaid,
                      label: Text(
                        '${settings.unpaidBreakDurationMinutes.toStringAsFixed(0)}\' ${l.add_shift_manual_unpaid_break}',
                      ),
                    ),
                  ],
                  selected: {_selectedBreakType},
                  onSelectionChanged: (val) =>
                      setState(() => _selectedBreakType = val.first),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppTheme.spaceSm),
          _FormSection(
            title: l.add_shift_manual_work_tips_section,
            icon: Icons.payments_outlined,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedJobTypeId,
                  decoration: InputDecoration(
                    labelText: l.add_shift_manual_job_type_label,
                    prefixIcon: const Icon(Icons.work_rounded),
                  ),
                  items: jobs
                      .map(
                        (j) => DropdownMenuItem<String>(
                          value: j.id,
                          child: Row(
                            children: [
                              Icon(AppTheme.iconForJobName(j.name), size: 18),
                              const SizedBox(width: 8),
                              Text(j.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedJobTypeId = val),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _buildTipsSection(_tipControllers, symbol),
                const SizedBox(height: AppTheme.spaceMd),
                _buildAutoExpensesSection(symbol),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveManual,
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(
                widget.shiftToEdit != null ? l.common_save : l.add_shift_title,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
        ],
      ),
    );
  }

  Widget _buildRawForm(List<JobType> jobs) {
    final l = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        AppTheme.spaceSm,
        120, // Bottom space for ads and system navigation
      ),
      child: Column(
        children: [
          _FormSection(
            title: l.add_shift_paste_title,
            icon: Icons.paste_rounded,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedJobTypeId,
                  decoration: InputDecoration(
                    labelText: l.add_shift_paste_default_job_label,
                    prefixIcon: const Icon(Icons.work_history_rounded),
                  ),
                  items: jobs
                      .map(
                        (j) => DropdownMenuItem<String>(
                          value: j.id,
                          child: Text(j.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedJobTypeId = val),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppTheme.primaryDark,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l.add_shift_paste_format_info,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Container(
            decoration: AppTheme.sectionDecoration(context),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minHeight: 200),
            child: TextField(
              controller: _rawTextController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: l.add_shift_paste_hint,
                alignLabelWithHint: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveRaw,
              icon: const Icon(Icons.bolt_rounded),
              label: Text(l.add_shift_paste_parse_button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(
    List<TextEditingController> controllers,
    String symbol,
  ) {
    final total = _calculateTotalTips(controllers);
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.add_shift_tips_title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.profit.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l.add_shift_tips_total} ${UIUtils.formatCurrency(total, symbol: symbol)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.profitSoft,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...controllers.asMap().entries.map((entry) {
          final idx = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkBackground.withValues(alpha: 0.4)
                    : AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Icon(
                    Icons.monetization_on_outlined,
                    size: 20,
                    color: AppTheme.profit.withValues(alpha: 0.8),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: l.add_shift_tips_hint,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (controllers.length > 1)
                    IconButton(
                      tooltip: l.common_cancel,
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AppTheme.expense,
                      ),
                      onPressed: () => setState(() {
                        controllers.removeAt(idx);
                      }),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() {
            controllers.add(TextEditingController(text: '0'));
          }),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l.add_shift_tips_add_button),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryDark),
        ),
      ],
    );
  }

  Widget _buildAutoExpensesSection(String symbol) {
    double total = 0;
    for (var c in _autoExpenseAmountControllers) {
      total += double.tryParse(c.text) ?? 0.0;
    }
    final l = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.add_shift_expenses_title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l.add_shift_expenses_total} -${UIUtils.formatCurrency(total, symbol: symbol)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.expenseSoft,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_autoExpenseAmountControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _autoExpenseDescControllers[index],
                    decoration: InputDecoration(
                      labelText: l.onboarding_auto_expenses_desc_label,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _autoExpenseAmountControllers[index],
                    decoration: InputDecoration(labelText: symbol),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.expense,
                  ),
                  onPressed: () => setState(() {
                    _autoExpenseAmountControllers.removeAt(index);
                    _autoExpenseDescControllers.removeAt(index);
                  }),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() {
            _autoExpenseAmountControllers.add(TextEditingController(text: '0'));
            _autoExpenseDescControllers.add(TextEditingController(text: ''));
          }),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: Text(l.add_shift_expenses_add_button),
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryDark),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      decoration: AppTheme.sectionDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryDark),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryDark, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(value, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
