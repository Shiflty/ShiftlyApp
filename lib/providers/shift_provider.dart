import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shiftly/models/expense.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/shift.dart';
import 'package:shiftly/models/shift_filter.dart';
import 'package:shiftly/services/api_service.dart';
import 'package:shiftly/services/google_drive_service.dart';
import 'package:shiftly/services/notification_service.dart';
import 'package:shiftly/services/persistence_service.dart';

class ShiftProvider with ChangeNotifier {
  final PersistenceService _persistence;
  final ApiService _apiService = ApiService();
  final GoogleDriveService _driveService = GoogleDriveService();
  String? _authToken;
  bool _isBYOS = false;

  ShiftProvider(this._persistence);

  void updateAuthStatus(String? token, bool isBYOS) {
    _authToken = token;
    final wasNotBYOS = !_isBYOS;
    _isBYOS = isBYOS;

    if (isBYOS && wasNotBYOS) {
      _triggerBackup();
      restoreFromBYOS(); // Automatic restore attempt on first connection
    }
  }

  DateTime? _lastBackupTime;

  DateTime? get lastBackupTime => _lastBackupTime;

  Future<void> _triggerBackup() async {
    if (_isBYOS) {
      try {
        final data = {
          'shifts': shifts.map((s) => s.toJson()).toList(),
          'expenses': expenses.map((e) => e.toJson()).toList(),
          'jobTypes': jobTypes.map((j) => j.toJson()).toList(),
        };
        await _driveService.uploadBackup(data);
        _lastBackupTime = DateTime.now();
        notifyListeners();
      } catch (e) {
        debugPrint('Backup failed: $e');
      }
    }
  }

  Future<void> restoreFromBYOS() async {
    if (!_isBYOS) return;
    try {
      final data = await _driveService.downloadBackup();
      if (data == null) return;

      if (data['jobTypes'] != null) {
        for (var jobData in data['jobTypes']) {
          final job = JobType.fromJson(jobData);
          await _persistence.jobTypesBox.put(job.id, job);
        }
      }

      if (data['expenses'] != null) {
        for (var expData in data['expenses']) {
          final exp = Expense.fromJson(expData);
          await _persistence.expensesBox.put(exp.id, exp);
        }
      }

      if (data['shifts'] != null) {
        for (var shiftData in data['shifts']) {
          final shift = Shift.fromJson(shiftData);
          await _persistence.shiftsBox.put(shift.id, shift);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Restore from BYOS failed: $e');
    }
  }

  Future<void> syncWithServer({bool? keepLocal}) async {
    if (_authToken == null) return;
    try {
      // 1. Get remote data
      final remoteJobTypes = await _apiService.getJobTypes(_authToken!);
      final remoteExpenses = await _apiService.getExpenses(_authToken!);
      final remoteShifts = await _apiService.getShifts(_authToken!);

      // 2. Handle conflicts if it's the first sync
      if (keepLocal == false) {
        // User chose server data - clear local
        await _persistence.shiftsBox.clear();
        await _persistence.jobTypesBox.clear();
        await _persistence.expensesBox.clear();
      }

      // 3. Save remote to local
      for (var jobData in remoteJobTypes) {
        final job = JobType(
          id: jobData['id'],
          name: jobData['name'],
          hourlyRate: double.parse(jobData['hourly_rate'].toString()),
        );
        await _persistence.jobTypesBox.put(job.id, job);
      }

      for (var expData in remoteExpenses) {
        final exp = Expense(
          id: expData['id'],
          date: DateTime.parse(expData['date']),
          description: expData['description'],
          amount: double.parse(expData['amount'].toString()),
        );
        await _persistence.expensesBox.put(exp.id, exp);
      }

      for (var shiftData in remoteShifts) {
        final shift = Shift(
          id: shiftData['id'],
          date: DateTime.parse(shiftData['date']),
          startTime: DateTime.parse(shiftData['start_time']),
          endTime: DateTime.parse(shiftData['end_time']),
          jobTypeId: shiftData['job_type_id'],
          tips: double.parse(shiftData['tips'].toString()),
          hourlyRate: double.parse(shiftData['hourly_rate'].toString()),
          unpaidBreakMinutes: double.parse(
            shiftData['unpaid_break_minutes']?.toString() ?? '0',
          ),
        );
        await _persistence.shiftsBox.put(shift.id, shift);
      }

      // 4. Upload local to server (if user chose to keep local or merge)
      if (keepLocal != false) {
        for (var job in jobTypes) {
          await _syncJobTypeToServer(job);
        }
        for (var exp in expenses) {
          await _syncExpenseToServer(exp);
        }
        for (var shift in shifts) {
          await _syncShiftToServer(shift);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }

  void updateAuthToken(String? token) {
    _authToken = token;
    // Don't auto-sync here anymore, let the AuthScreen handle it once to ask for preference
  }

  Future<void> _syncJobTypeToServer(JobType job) async {
    if (_authToken == null) return;
    await _apiService.upsertJobType(_authToken!, {
      'id': job.id,
      'name': job.name,
      'hourly_rate': job.hourlyRate,
      'wage_history': job.wageHistory
          ?.map(
            (e) => {
              'startDate': e.startDate.toIso8601String(),
              'hourlyRate': e.hourlyRate,
            },
          )
          .toList(),
    });
  }

  Future<void> _syncExpenseToServer(Expense expense) async {
    if (_authToken == null) return;
    await _apiService.upsertExpense(_authToken!, {
      'id': expense.id,
      'date': expense.date.toIso8601String().split('T')[0],
      'description': expense.description,
      'amount': expense.amount,
    });
  }

  Future<void> _syncShiftToServer(Shift shift) async {
    if (_authToken == null) return;
    final job = getJobTypeById(shift.jobTypeId);
    final rate = shift.hourlyRate ?? job?.getRateForDate(shift.date) ?? 0.0;

    await _apiService.upsertShift(_authToken!, {
      'id': shift.id,
      'job_type_id': shift.jobTypeId,
      'date': shift.date.toIso8601String().split('T')[0],
      'start_time': shift.startTime.toIso8601String(),
      'end_time': shift.endTime.toIso8601String(),
      'tips': shift.tips,
      'break_type': shift.breakType?.toString().split('.').last,
      'unpaid_break_minutes': shift.unpaidBreakMinutes,
      'hourly_rate': rate,
      'automatic_expenses': shift.automaticExpenses
          ?.map((e) => {'description': e.description, 'amount': e.amount})
          .toList(),
      'total_pay': shift.calculateTotalPay(rate),
    });
  }

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
    final ShiftFilter? filter = _activeFilter;
    if (filter == null || !filter.isActive) return allShifts;

    return allShifts.where((shift) {
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

      if (filter.typeIds != null &&
          filter.typeIds!.isNotEmpty &&
          !filter.typeIds!.contains(shift.jobTypeId)) {
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
    _syncShiftToServer(shift);
    _triggerBackup();
    notifyListeners();
  }

  Future<void> updateShift(Shift shift, {Map<String, String>? l10n}) async {
    await shift.save();
    _scheduleReminder(shift, l10n: l10n);
    _syncShiftToServer(shift);
    _triggerBackup();
    notifyListeners();
  }

  Future<void> deleteShift(String id) async {
    await _persistence.shiftsBox.delete(id);
    NotificationService.cancelNotification(id.hashCode);
    if (_authToken != null) {
      await _apiService.deleteShift(_authToken!, id);
    }
    _triggerBackup();
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
    _syncExpenseToServer(expense);
    _triggerBackup();
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
    _syncExpenseToServer(expense);
    _triggerBackup();
    notifyListeners();
  }

  Future<void> deleteExpense(String id) async {
    await _persistence.expensesBox.delete(id);
    if (_authToken != null) {
      await _apiService.deleteExpense(_authToken!, id);
    }
    _triggerBackup();
    notifyListeners();
  }

  Future<void> addJobType(JobType jobType) async {
    await _persistence.jobTypesBox.put(jobType.id, jobType);
    _syncJobTypeToServer(jobType);
    _triggerBackup();
    notifyListeners();
  }

  Future<void> updateJobType(JobType jobType) async {
    if (jobType.isInBox) {
      await jobType.save();
    } else {
      await _persistence.jobTypesBox.put(jobType.id, jobType);
    }
    _syncJobTypeToServer(jobType);
    _triggerBackup();
    // Keep shift snapshots in sync with the updated wage history
    await _resyncShiftRatesForJob(jobType);
    notifyListeners();
  }

  Future<void> deleteJobType(String id) async {
    await _persistence.jobTypesBox.delete(id);
    if (_authToken != null) {
      await _apiService.deleteJobType(_authToken!, id);
    }
    _triggerBackup();
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
