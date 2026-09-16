import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shiftly/models/expense.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_filter.dart';
import 'package:shiftly/services/notification_service.dart';
import 'package:shiftly/services/persistence_service.dart';

class ShiftProvider with ChangeNotifier {
  final PersistenceService _persistence;

  ShiftProvider(this._persistence);

  ShiftFilter? _activeFilter;

  ShiftFilter? get activeFilter => _activeFilter;

  void setFilter(ShiftFilter? filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _activeFilter = null;
    notifyListeners();
  }

  // Shifts
  List<Shift> get shifts =>
      _persistence.shiftsBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<Shift> get filteredShifts {
    final allShifts = shifts;
    if (_activeFilter == null || !_activeFilter!.isActive) return allShifts;

    return allShifts.where((shift) {
      final filter = _activeFilter!;
      final job = getJobTypeById(shift.jobTypeId);
      final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 40.22;
      final totalPay = shift.calculateTotalPay(rate);

      if (filter.minWage != null && totalPay < filter.minWage!) return false;
      if (filter.maxWage != null && totalPay > filter.maxWage!) return false;

      if (filter.minTips != null && shift.tips < filter.minTips!) return false;
      if (filter.maxTips != null && shift.tips > filter.maxTips!) return false;

      final expenses = shift.totalAutomaticExpenses;
      if (filter.minExpenses != null && expenses < filter.minExpenses!) {
        return false;
      }
      if (filter.maxExpenses != null && expenses > filter.maxExpenses!) {
        return false;
      }

      final duration = shift.netHours;
      if (filter.minDuration != null && duration < filter.minDuration!) {
        return false;
      }
      if (filter.maxDuration != null && duration > filter.maxDuration!) {
        return false;
      }

      if (filter.startDate != null && shift.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && shift.date.isAfter(filter.endDate!)) {
        return false;
      }

      if (filter.jobTypeId != null && shift.jobTypeId != filter.jobTypeId) {
        return false;
      }

      return true;
    }).toList();
  }

  // Expenses
  List<Expense> get expenses =>
      _persistence.expensesBox.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<JobType> get jobTypes => _persistence.jobTypesBox.values.toList();

  bool get _remindersEnabled =>
      _persistence.settingsBox.get('shiftRemindersEnabled', defaultValue: true);

  double get _reminderDuration => _persistence.settingsBox.get(
    'shiftReminderDurationHours',
    defaultValue: 4.0,
  );

  Future<void> addShift(Shift shift, {Map<String, String>? l10n}) async {
    await _persistence.shiftsBox.put(shift.id, shift);
    _scheduleReminder(shift, l10n: l10n);
    notifyListeners();
  }

  Future<void> updateShift(Shift shift, {Map<String, String>? l10n}) async {
    await shift.save();
    _scheduleReminder(shift, l10n: l10n);
    notifyListeners();
  }

  Future<void> deleteShift(String id) async {
    await _persistence.shiftsBox.delete(id);
    NotificationService.cancelNotification(id.hashCode);
    notifyListeners();
  }

  void _scheduleReminder(Shift shift, {Map<String, String>? l10n}) {
    if (!_remindersEnabled || l10n == null) return;

    final job = getJobTypeById(shift.jobTypeId);
    NotificationService.scheduleShiftReminder(
      id: shift.id.hashCode,
      shiftName: job?.name ?? 'Shift',
      startTime: shift.startTime,
      reminderDurationHours: _reminderDuration,
      title: l10n['title'] ?? 'Shift Reminder',
      bodyTemplate: l10n['body'] ?? 'Your shift ({name}) starts in {time}!',
      hoursLabel: l10n['hours'] ?? 'hours',
      minutesLabel: l10n['minutes'] ?? 'minutes',
      channelName: l10n['channelName'] ?? 'Shift Reminders',
      channelDescription:
          l10n['channelDesc'] ?? 'Reminders before shift starts',
    );
  }

  void refreshAllReminders(Map<String, String> l10n) {
    // Cancel all first
    for (var shift in shifts) {
      NotificationService.cancelNotification(shift.id.hashCode);
    }

    // Schedule only if enabled
    if (_remindersEnabled) {
      for (var shift in shifts) {
        _scheduleReminder(shift, l10n: l10n);
      }
    }
  }

  // Expense Methods
  Future<void> addExpense(Expense expense) async {
    await _persistence.expensesBox.put(expense.id, expense);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _persistence.expensesBox.delete(id);
    notifyListeners();
  }

  Future<void> addJobType(JobType jobType) async {
    await _persistence.jobTypesBox.put(jobType.id, jobType);
    notifyListeners();
  }

  Future<void> updateJobType(JobType jobType) async {
    if (jobType.isInBox) {
      await jobType.save();
    } else {
      await _persistence.jobTypesBox.put(jobType.id, jobType);
    }
    // Keep shift snapshots in sync with the updated wage history
    await _resyncShiftRatesForJob(jobType);
    notifyListeners();
  }

  /// Re-applies [JobType.getRateForDate] onto every shift for this job so
  /// wage history edits (raises, reverts, effective-date changes) show up
  /// immediately without requiring each shift to be re-saved.
  Future<void> _resyncShiftRatesForJob(JobType job) async {
    for (final shift in _persistence.shiftsBox.values) {
      if (shift.jobTypeId != job.id) continue;
      final rate = job.getRateForDate(shift.date);
      if (shift.hourlyRate != rate) {
        shift.hourlyRate = rate;
        await shift.save();
      }
    }
  }

  Future<void> deleteJobType(String id) async {
    await _persistence.jobTypesBox.delete(id);
    notifyListeners();
  }

  JobType? getJobTypeById(String id) {
    // Try key lookup first
    var job = _persistence.jobTypesBox.get(id);
    if (job != null) return job;

    // Fallback: search by id field in case keys are indexed differently
    return jobTypes.firstWhereOrNull((j) => j.id == id);
  }

  Map<String, List<Shift>> get shiftsGroupedByMonth {
    return groupBy(
      filteredShifts,
      (Shift s) => "${s.date.year}-${s.date.month.toString().padLeft(2, '0')}",
    );
  }

  Map<String, List<Expense>> get expensesGroupedByMonth {
    return groupBy(
      expenses,
      (Expense e) =>
          "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}",
    );
  }

  // ── Filter Helpers ────────────────────────────────────────────────
  double get maxCapturedWage {
    if (shifts.isEmpty) return 0;
    return shifts
        .map((s) {
          final job = getJobTypeById(s.jobTypeId);
          final rate = s.hourlyRate ?? job?.getRateForDate(s.date) ?? 40.22;
          return s.calculateTotalPay(rate);
        })
        .reduce((a, b) => a > b ? a : b);
  }

  double get maxCapturedTips {
    if (shifts.isEmpty) return 0;
    return shifts.map((s) => s.tips).reduce((a, b) => a > b ? a : b);
  }

  double get maxCapturedExpenses {
    if (shifts.isEmpty) return 0;
    return shifts
        .map((s) => s.totalAutomaticExpenses)
        .reduce((a, b) => a > b ? a : b);
  }

  double get maxCapturedDuration {
    if (shifts.isEmpty) return 0;
    return shifts.map((s) => s.netHours).reduce((a, b) => a > b ? a : b);
  }

  Future<void> factoryReset() async {
    // 1. Cancel all notifications
    for (var shift in shifts) {
      NotificationService.cancelNotification(shift.id.hashCode);
    }
    // 2. Clear persistence
    await _persistence.deleteAllData();
    // 3. Notify listeners
    notifyListeners();
  }
}
