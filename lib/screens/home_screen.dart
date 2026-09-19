import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_filter.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/providers/timer_provider.dart';
import 'package:shiftly/screens/add_shift_screen.dart';
import 'package:shiftly/screens/calendar_screen.dart';
import 'package:shiftly/screens/expenses_screen.dart';
import 'package:shiftly/screens/settings_screen.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final timerProvider = context.watch<TimerProvider>();
    final auth = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context)!;
    final groupedShifts = shiftProvider.shiftsGroupedByMonth;

    double grandTotalNetHours = 0;
    double grandTotalBaseSalary = 0;
    double grandTotalTips = 0;
    double grandTotalExpenses = 0;
    int grandTotalShifts = shiftProvider.filteredShifts.length;

    for (var shift in shiftProvider.filteredShifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      grandTotalNetHours += shift.netHours;
      grandTotalBaseSalary += shift.netHours * rate;
      grandTotalTips += shift.tips;
      grandTotalExpenses += shift.totalAutomaticExpenses;
    }

    for (var expense in shiftProvider.expenses) {
      grandTotalExpenses += expense.amount;
    }

    if (timerProvider.startTime != null) {
      grandTotalShifts += 1;
      final settings = context.read<SettingsProvider>();
      final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
      final rate = job?.getRateForDate(timerProvider.startTime!) ?? 40.22;
      grandTotalNetHours += timerProvider.netMinutes / 60.0;
      grandTotalBaseSalary += (timerProvider.netMinutes / 60.0) * rate;
      grandTotalTips += timerProvider.tips;
      if (settings.automaticExpenseEnabled) {
        for (var e in settings.defaultAutomaticExpenses) {
          grandTotalExpenses += e.amount;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              tooltip: l.home_action_calendar,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long_rounded),
              tooltip: l.expenses_title,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpensesScreen()),
              ),
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              l.common_app_name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            if (auth.isLoggedIn && auth.userName != null)
              Text(
                l.home_welcome_back.replaceFirst('[[name]]', auth.userName!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              shiftProvider.activeFilter?.isActive == true
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_outlined,
              color: shiftProvider.activeFilter?.isActive == true
                  ? AppTheme.primary
                  : null,
            ),
            tooltip: l.filter_title,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const _FilterBottomSheet(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l.settings_title,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: AppTheme.spaceXs),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (timerProvider.startTime != null)
              _ActiveTimerBanner(timer: timerProvider),
            if (shiftProvider.activeFilter?.isActive == true)
              const _ActiveFiltersBar(),
            Expanded(
              child: groupedShifts.isEmpty && timerProvider.startTime == null
                  ? (shiftProvider.activeFilter?.isActive == true
                        ? _FilterEmptyState()
                        : _EmptyState())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spaceSm,
                        AppTheme.spaceXs,
                        AppTheme.spaceSm,
                        120, // Increased for ad space and system navigation
                      ),
                      itemCount: groupedShifts.isEmpty
                          ? 1
                          : groupedShifts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _GrandTotalCard(
                            totalHours: grandTotalNetHours,
                            totalBase: grandTotalBaseSalary,
                            totalTips: grandTotalTips,
                            totalExpenses: grandTotalExpenses,
                            totalShifts: grandTotalShifts,
                          );
                        }
                        final monthKey = groupedShifts.keys.elementAt(
                          index - 1,
                        );
                        final shifts = groupedShifts[monthKey]!;
                        return _MonthExpansionSection(
                          monthKey: monthKey,
                          shifts: shifts,
                          initiallyExpanded: index == 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const AddShiftScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          ),
        ),
        label: Text(l.home_action_new_shift),
        icon: const Icon(Icons.add_rounded),
        tooltip: l.home_action_new_shift,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 56,
                  color: AppTheme.primary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                l.home_empty_state_title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                l.home_empty_state_subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveTimerBanner extends StatelessWidget {
  final TimerProvider timer;

  const _ActiveTimerBanner({required this.timer});

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.read<ShiftProvider>();
    final l = AppLocalizations.of(context)!;
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    final job = shiftProvider.getJobTypeById(timer.jobTypeId ?? "");
    final rate = timer.startTime != null
        ? (job?.getRateForDate(timer.startTime!) ?? 40.22)
        : (job?.hourlyRate ?? 40.22);
    final pay = timer.calculateLivePay(rate);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final d = timer.elapsed;
    final timeStr =
        "${d.inHours}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";

    final isBreak = timer.isOnBreak;
    final accent = isBreak ? AppTheme.warningSoft : AppTheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScalePress(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddShiftScreen(initialTabIndex: 0),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppTheme.spaceSm,
          AppTheme.spaceXs,
          AppTheme.spaceSm,
          AppTheme.spaceSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isBreak
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                color: accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBreak
                        ? l.home_active_timer_break
                        : '${l.home_active_timer_active} ${job?.name ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? accent : accent.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l.home_active_timer_time} $timeStr  ·  ${UIUtils.formatCurrency(pay, symbol: symbol)}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontFamily: 'monospace',
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: accent),
          ],
        ),
      ),
    );
  }
}

class _GrandTotalCard extends StatelessWidget {
  final double totalHours;
  final double totalBase;
  final double totalTips;
  final double totalExpenses;
  final int totalShifts;

  const _GrandTotalCard({
    required this.totalHours,
    required this.totalBase,
    required this.totalTips,
    required this.totalExpenses,
    required this.totalShifts,
  });

  @override
  Widget build(BuildContext context) {
    final net = totalBase + totalTips - totalExpenses;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final symbol = context.watch<SettingsProvider>().currencySymbol;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppTheme.spaceMd,
        top: AppTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF0EA5E9),
                  const Color(0xFF0369A1),
                  const Color(0xFF1E293B),
                ]
              : [
                  const Color(0xFF38BDF8),
                  const Color(0xFF0EA5E9),
                  const Color(0xFF0284C7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.25 : 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Stack(
          children: [
            // Soft glass overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -40,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              child: Column(
                children: [
                  Text(
                    l.home_total_card_title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    UIUtils.formatCurrency(net, symbol: symbol),
                    style: AppTheme.monoNumber.copyWith(
                      color: net < 0 ? const Color(0xFFFECACA) : Colors.white,
                      fontSize: 40,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: AppTheme.spaceXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _HeaderInfoItem(
                          label: l.common_shifts_count,
                          value: totalShifts.toString(),
                        ),
                        _VerticalDivider(),
                        _HeaderInfoItem(
                          label: l.home_total_card_hours,
                          value: totalHours.toStringAsFixed(2),
                        ),
                        _VerticalDivider(),
                        _HeaderInfoItem(
                          label: l.home_total_card_base,
                          value: UIUtils.formatCurrency(
                            totalBase,
                            symbol: symbol,
                          ),
                          amount: totalBase,
                        ),
                        _VerticalDivider(),
                        _HeaderInfoItem(
                          label: l.home_total_card_tips,
                          value: UIUtils.formatCurrency(
                            totalTips,
                            symbol: symbol,
                          ),
                          amount: totalTips,
                        ),
                        _VerticalDivider(),
                        _HeaderInfoItem(
                          label: l.home_total_card_expenses,
                          value: UIUtils.formatCurrency(
                            totalExpenses,
                            symbol: symbol,
                          ),
                          amount: -totalExpenses,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final double? amount;

  const _HeaderInfoItem({
    required this.label,
    required this.value,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: (amount ?? 0) < 0 ? const Color(0xFFFECACA) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

class _MonthExpansionSection extends StatelessWidget {
  final String monthKey;
  final List<Shift> shifts;
  final bool initiallyExpanded;

  const _MonthExpansionSection({
    required this.monthKey,
    required this.shifts,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.read<ShiftProvider>();
    final l = AppLocalizations.of(context)!;
    final symbol = context.watch<SettingsProvider>().currencySymbol;

    double totalNetHours = 0;
    double totalBaseSalary = 0;
    double totalTips = 0;
    double totalMonthExpenses = 0;
    int monthShiftCount = shifts.length;

    for (var shift in shifts) {
      final job = shiftProvider.getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      totalNetHours += shift.netHours;
      totalBaseSalary += shift.netHours * rate;
      totalTips += shift.tips;
      totalMonthExpenses += shift.totalAutomaticExpenses;
    }

    final allExpenses = shiftProvider.expensesGroupedByMonth[monthKey] ?? [];
    for (var expense in allExpenses) {
      totalMonthExpenses += expense.amount;
    }

    final date = DateTime.parse("$monthKey-01");
    final monthName = DateFormat.MMMM(l.localeName).format(date);
    final year = date.year;

    final timerProvider = context.watch<TimerProvider>();
    if (timerProvider.startTime != null &&
        timerProvider.startTime!.year == year &&
        timerProvider.startTime!.month == date.month) {
      monthShiftCount += 1;
      final settings = context.read<SettingsProvider>();
      final job = shiftProvider.getJobTypeById(timerProvider.jobTypeId ?? "");
      final rate = job?.getRateForDate(timerProvider.startTime!) ?? 40.22;
      totalNetHours += timerProvider.netMinutes / 60.0;
      totalBaseSalary += (timerProvider.netMinutes / 60.0) * rate;
      totalTips += timerProvider.tips;
      if (settings.automaticExpenseEnabled) {
        for (var e in settings.defaultAutomaticExpenses) {
          totalMonthExpenses += e.amount;
        }
      }
    }

    final net = totalBaseSalary + totalTips - totalMonthExpenses;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
          ),
          collapsedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceSm + 4,
            vertical: AppTheme.spaceXs,
          ),
          childrenPadding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
          title: Text(
            "$monthName $year",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "$monthShiftCount ${l.common_shifts_count}  · ${l.home_shift_list_net_total}: ${UIUtils.formatCurrency(net, symbol: symbol)} ·  ${totalNetHours.toStringAsFixed(2)} ${l.common_hours_suffix}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          children: [
            const Divider(height: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceSm),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SummaryItem(
                      label: l.home_total_card_base,
                      value: UIUtils.formatCurrency(
                        totalBaseSalary,
                        symbol: symbol,
                      ),
                      amount: totalBaseSalary,
                    ),
                    const VerticalDivider(width: 1, indent: 4, endIndent: 4),
                    _SummaryItem(
                      label: l.home_total_card_tips,
                      value: UIUtils.formatCurrency(totalTips, symbol: symbol),
                      amount: totalTips,
                      accent: AppTheme.profit,
                    ),
                    const VerticalDivider(width: 1, indent: 4, endIndent: 4),
                    _SummaryItem(
                      label: l.home_total_card_expenses,
                      value: UIUtils.formatCurrency(
                        totalMonthExpenses,
                        symbol: symbol,
                      ),
                      amount: -totalMonthExpenses,
                    ),
                    const VerticalDivider(width: 1, indent: 4, endIndent: 4),
                    _SummaryItem(
                      label: l.common_net,
                      value: UIUtils.formatCurrency(net, symbol: symbol),
                      isBold: true,
                      amount: net,
                    ),
                  ],
                ),
              ),
            ),
            ...shifts.map((shift) => _ShiftTile(shift: shift)),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double? amount;
  final Color? accent;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.amount,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    Color? textColor;
    if ((amount ?? 0) < 0) {
      textColor = AppTheme.expense;
    } else if (isBold) {
      textColor = AppTheme.primaryDark;
    } else if (accent != null) {
      textColor = accent;
    }

    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _ShiftTile extends StatelessWidget {
  final Shift shift;

  const _ShiftTile({required this.shift});

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.read<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final l = AppLocalizations.of(context)!;
    final job = shiftProvider.getJobTypeById(shift.jobTypeId);
    final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
    final pay = shift.calculateTotalPay(rate);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final breakType = shift.breakType ?? BreakType.none;

    return Dismissible(
      key: Key(shift.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSm,
          vertical: AppTheme.spaceXs / 2,
        ),
        decoration: BoxDecoration(
          color: AppTheme.expense.withValues(alpha: isDark ? 0.2 : 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spaceMd),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: AppTheme.expenseSoft,
        ),
      ),
      confirmDismiss: (direction) async {
        final dateStr = DateFormat('dd/MM/yyyy').format(shift.date);
        return await UIUtils.showConfirmDialog(
          context: context,
          title: l.add_shift_delete_title,
          content: '${l.add_shift_delete_desc} $dateStr?',
          isDestructive: true,
          confirmLabel: l.common_delete,
        );
      },
      onDismissed: (_) {
        final dateStr = DateFormat('dd/MM/yyyy').format(shift.date);
        shiftProvider.deleteShift(shift.id);

        UIUtils.showSnackBar(
          context,
          '$dateStr ${l.add_shift_delete_msg}',
          action: SnackBarAction(
            label: l.common_cancel,
            onPressed: () {
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
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      AddShiftScreen(shiftToEdit: shift),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                          child: child,
                        );
                      },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceXs,
                vertical: 10,
              ),
              child: Row(
                children: [
                  // Date badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.d().format(shift.date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.primaryDark,
                            height: 1,
                          ),
                        ),
                        Text(
                          DateFormat.E(l.localeName).format(shift.date),
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              AppTheme.iconForJobName(job?.name),
                              size: 16,
                              color: AppTheme.primaryDark,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                job?.name ?? l.common_error,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${DateFormat.Hm().format(shift.startTime)} – ${DateFormat.Hm().format(shift.endTime)}  ·  ${shift.netHours.toStringAsFixed(2)} ${l.common_hours_suffix}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (shift.tips > 0 || breakType != BreakType.none) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (shift.tips > 0)
                                _ShiftTag(
                                  label:
                                      '+${UIUtils.formatCurrency(shift.tips, symbol: settings.currencySymbol)}',
                                  icon: Icons.payments_outlined,
                                  color: AppTheme.profit,
                                ),
                              if (breakType == BreakType.paid)
                                _ShiftTag(
                                  label:
                                      "${settings.paidBreakDurationMinutes.toStringAsFixed(0)} ${l.common_min_suffix} ${l.add_shift_manual_paid_break}",
                                  icon: Icons.timer_outlined,
                                  color: AppTheme.primary,
                                ),
                              if (breakType == BreakType.unpaid)
                                _ShiftTag(
                                  label:
                                      "${(shift.unpaidBreakMinutes ?? settings.unpaidBreakDurationMinutes).toStringAsFixed(0)} ${l.common_min_suffix} ${l.add_shift_manual_unpaid_break}",
                                  icon: Icons.coffee_outlined,
                                  color: AppTheme.warningSoft,
                                ),
                              if (shift.totalAutomaticExpenses > 0)
                                _ShiftTag(
                                  label:
                                      '-${UIUtils.formatCurrency(shift.totalAutomaticExpenses, symbol: settings.currencySymbol)}',
                                  icon: Icons.money_off_rounded,
                                  color: AppTheme.expense,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceXs),
                  Text(
                    UIUtils.formatCurrency(
                      pay,
                      symbol: settings.currencySymbol,
                    ),
                    style: UIUtils.getCurrencyStyle(
                      context,
                      pay,
                      positiveColor: AppTheme.primaryDark,
                      baseStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ShiftTag({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.warningSoft.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.filter_list_off_rounded,
                  size: 56,
                  color: AppTheme.warningSoft.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                l.filter_empty_state_title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spaceXs),
              Text(
                l.filter_empty_state_subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              TextButton.icon(
                onPressed: () => context.read<ShiftProvider>().clearFilter(),
                icon: const Icon(Icons.clear_all_rounded),
                label: Text(l.filter_clear_all),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShiftProvider>();
    final filter = provider.activeFilter;
    if (filter == null || !filter.isActive) return const SizedBox.shrink();

    final l = AppLocalizations.of(context)!;
    final symbol = context.read<SettingsProvider>().currencySymbol;

    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
        children: [
          Center(
            child: Text(
              l.filter_active_filters,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          if (filter.minWage != null || filter.maxWage != null)
            _ActiveFilterChip(
              label: l.filter_chip_wage
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(filter.minWage ?? 0, symbol: symbol),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxWage ?? 5000,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinWage: true, clearMaxWage: true),
              ),
            ),
          if (filter.minTips != null || filter.maxTips != null)
            _ActiveFilterChip(
              label: l.filter_chip_tips
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(filter.minTips ?? 0, symbol: symbol),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxTips ?? 1000,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinTips: true, clearMaxTips: true),
              ),
            ),
          if (filter.minExpenses != null || filter.maxExpenses != null)
            _ActiveFilterChip(
              label: l.filter_chip_expenses
                  .replaceFirst(
                    '[[min]]',
                    UIUtils.formatCurrency(
                      filter.minExpenses ?? 0,
                      symbol: symbol,
                    ),
                  )
                  .replaceFirst(
                    '[[max]]',
                    UIUtils.formatCurrency(
                      filter.maxExpenses ?? 500,
                      symbol: symbol,
                    ),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinExpenses: true, clearMaxExpenses: true),
              ),
            ),
          if (filter.minDuration != null || filter.maxDuration != null)
            _ActiveFilterChip(
              label: l.filter_chip_duration
                  .replaceFirst(
                    '[[min]]',
                    (filter.minDuration ?? 0).toStringAsFixed(1),
                  )
                  .replaceFirst(
                    '[[max]]',
                    (filter.maxDuration ?? 24).toStringAsFixed(1),
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearMinDuration: true, clearMaxDuration: true),
              ),
            ),
          if (filter.startDate != null || filter.endDate != null)
            _ActiveFilterChip(
              label: l.filter_chip_date
                  .replaceFirst(
                    '[[start]]',
                    filter.startDate != null
                        ? DateFormat('dd/MM').format(filter.startDate!)
                        : '...',
                  )
                  .replaceFirst(
                    '[[end]]',
                    filter.endDate != null
                        ? DateFormat('dd/MM').format(filter.endDate!)
                        : '...',
                  ),
              onDeleted: () => provider.setFilter(
                filter.copyWith(clearStartDate: true, clearEndDate: true),
              ),
            ),
          if (filter.typeIds != null && filter.typeIds!.isNotEmpty)
            _ActiveFilterChip(
              label: l.filter_chip_job.replaceFirst(
                '[[name]]',
                filter.typeIds!.length == 1
                    ? provider.getJobTypeById(filter.typeIds!.first)?.name ??
                          '?'
                    : '${filter.typeIds!.length} ${l.common_shifts_count}',
              ),
              onDeleted: () =>
                  provider.setFilter(filter.copyWith(clearTypeIds: true)),
            ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => provider.clearFilter(),
            child: Text(
              l.filter_clear_all,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _ActiveFilterChip({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ShiftFilter _filter;

  @override
  void initState() {
    super.initState();
    final active = context.read<ShiftProvider>().activeFilter;
    if (active != null) {
      _filter = active;
    } else {
      final jobTypes = context.read<ShiftProvider>().jobTypes;
      _filter = ShiftFilter(
        typeIds: jobTypes.isNotEmpty ? [jobTypes.first.id] : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final shiftProvider = context.read<ShiftProvider>();
    final jobTypes = shiftProvider.jobTypes;
    final symbol = context.read<SettingsProvider>().currencySymbol;

    // Calculate dynamic maximums
    double maxWage = shiftProvider.maxCapturedWage;
    if (maxWage == 0) maxWage = 500;

    double maxTips = shiftProvider.maxCapturedTips;
    if (maxTips == 0) maxTips = 500;

    double maxExpenses = shiftProvider.maxCapturedExpenses;
    if (maxExpenses == 0) maxExpenses = 500;

    double maxDuration = shiftProvider.maxCapturedDuration;
    if (maxDuration == 0) maxDuration = 24;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceMd,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              AppTheme.spaceMd,
              0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.filter_title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filter = ShiftFilter();
                    });
                  },
                  child: Text(
                    l.filter_clear_all,
                  ), // Label might be "איפוס סינון" in ARB
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceMd,
                0,
                AppTheme.spaceMd,
                40, // Spacing for navigation buttons
              ),
              children: [
                _buildRangeSection(
                  title: l.filter_wage_range,
                  min: 0,
                  max: maxWage,
                  values: RangeValues(
                    (_filter.minWage ?? 0).clamp(0, maxWage),
                    (_filter.maxWage ?? maxWage).clamp(0, maxWage),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minWage: v.start,
                        maxWage: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_tips_range,
                  min: 0,
                  max: maxTips,
                  values: RangeValues(
                    (_filter.minTips ?? 0).clamp(0, maxTips),
                    (_filter.maxTips ?? maxTips).clamp(0, maxTips),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minTips: v.start,
                        maxTips: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_expenses_range,
                  min: 0,
                  max: maxExpenses,
                  values: RangeValues(
                    (_filter.minExpenses ?? 0).clamp(0, maxExpenses),
                    (_filter.maxExpenses ?? maxExpenses).clamp(0, maxExpenses),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minExpenses: v.start,
                        maxExpenses: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) =>
                      UIUtils.formatCurrency(v, symbol: symbol),
                ),
                _buildRangeSection(
                  title: l.filter_duration_range,
                  min: 0,
                  max: maxDuration,
                  values: RangeValues(
                    (_filter.minDuration ?? 0).clamp(0, maxDuration),
                    (_filter.maxDuration ?? maxDuration).clamp(0, maxDuration),
                  ),
                  onChanged: (v) {
                    setState(() {
                      _filter = _filter.copyWith(
                        minDuration: v.start,
                        maxDuration: v.end,
                      );
                    });
                  },
                  labelBuilder: (v) => v.toStringAsFixed(1),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l.filter_date_range,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _filter.startDate != null && _filter.endDate != null
                          ? "${DateFormat.yMd().format(_filter.startDate!)} - ${DateFormat.yMd().format(_filter.endDate!)}"
                          : l.common_start,
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange:
                            _filter.startDate != null && _filter.endDate != null
                            ? DateTimeRange(
                                start: _filter.startDate!,
                                end: _filter.endDate!,
                              )
                            : null,
                      );
                      if (range != null) {
                        setState(() {
                          _filter = _filter.copyWith(
                            startDate: range.start,
                            endDate: range.end,
                          );
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                _buildJobTypeMultiSelect(jobTypes),
                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceMd,
              0,
              AppTheme.spaceMd,
              24, // Spacing for buttons
            ),
            child: ElevatedButton(
              onPressed: () {
                if (_filter.typeIds == null || _filter.typeIds!.isEmpty) {
                  UIUtils.showSnackBar(
                    context,
                    l.filter_error_no_job_selected,
                    isError: true,
                  );
                  return;
                }
                shiftProvider.setFilter(_filter);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l.filter_apply),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeMultiSelect(List<JobType> jobTypes) {
    final l = AppLocalizations.of(context)!;
    final selectedIds = _filter.typeIds ?? [];
    final allSelected =
        jobTypes.isNotEmpty && selectedIds.length == jobTypes.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.filter_job_type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (jobTypes.length > 1)
              TextButton(
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      _filter = _filter.copyWith(typeIds: []);
                    } else {
                      _filter = _filter.copyWith(
                        typeIds: jobTypes.map((j) => j.id).toList(),
                      );
                    }
                  });
                },
                child: Text(
                  allSelected ? l.filter_clear_all : l.filter_select_all,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: jobTypes.map((JobType job) {
                final isSelected = selectedIds.contains(job.id);
                return CheckboxListTile(
                  title: Text(job.name, style: const TextStyle(fontSize: 14)),
                  value: isSelected,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  dense: true,
                  onChanged: (bool? value) {
                    setState(() {
                      final newList = List<String>.from(selectedIds);
                      if (value == true) {
                        newList.add(job.id);
                      } else {
                        newList.remove(job.id);
                      }
                      _filter = _filter.copyWith(typeIds: newList);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSection({
    required String title,
    required double min,
    required double max,
    required RangeValues values,
    required ValueChanged<RangeValues> onChanged,
    required String Function(double) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              "${labelBuilder(values.start)} - ${labelBuilder(values.end)}",
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: max > min ? (max - min).toInt().clamp(1, 10000) : 1,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
