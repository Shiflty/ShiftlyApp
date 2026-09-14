import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shiftly/models/break_type.dart';
import 'package:shiftly/services/notification_service.dart';
import 'package:shiftly/services/persistence_service.dart';

class TimerProvider with ChangeNotifier {
  final PersistenceService persistence;

  TimerProvider(this.persistence) {
    _loadState();
  }

  static const int timerNotificationId = 9999;

  DateTime? _startTime;
  String? _jobTypeId;
  bool _isRunning = false;
  DateTime? _reviewEndTime;

  // Break state
  BreakType? _activeBreakType;
  DateTime? _breakStartTime;
  double _accumulatedUnpaidMinutes = 0;
  double _totalPaidBreakMinutes = 0;

  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  Duration _breakRemaining = Duration.zero;

  DateTime? get startTime => _startTime;

  String? get jobTypeId => _jobTypeId;

  bool get isRunning => _isRunning;

  DateTime? get reviewEndTime => _reviewEndTime;

  BreakType? get activeBreakType => _activeBreakType;

  bool get isOnBreak => _activeBreakType != null;

  double get accumulatedUnpaidMinutes => _accumulatedUnpaidMinutes;

  Duration get elapsed => _elapsed;

  Duration get breakRemaining => _breakRemaining;

  void _loadState() {
    final box = persistence.settingsBox;
    final startMillis = box.get('timer_start');
    if (startMillis != null) {
      _startTime = DateTime.fromMillisecondsSinceEpoch(startMillis);
      _jobTypeId = box.get('timer_job_id');
      _isRunning = box.get('timer_running', defaultValue: false);
      _accumulatedUnpaidMinutes = box.get(
        'timer_unpaid_break',
        defaultValue: 0.0,
      );

      final breakTypeIdx = box.get('timer_break_type');
      if (breakTypeIdx != null) {
        _activeBreakType = BreakType.values[breakTypeIdx];
        final breakStartMillis = box.get('timer_break_start');
        if (breakStartMillis != null) {
          _breakStartTime = DateTime.fromMillisecondsSinceEpoch(
            breakStartMillis,
          );
        }
      }

      if (_isRunning) {
        _startTicker();
      } else if (_startTime != null) {
        _reviewEndTime = DateTime.fromMillisecondsSinceEpoch(
          box.get(
            'timer_review_end',
            defaultValue: DateTime.now().millisecondsSinceEpoch,
          ),
        );
        _updateElapsed();
      }
    }
  }

  void _persistState() {
    final box = persistence.settingsBox;
    box.put('timer_start', _startTime?.millisecondsSinceEpoch);
    box.put('timer_job_id', _jobTypeId);
    box.put('timer_running', _isRunning);
    box.put('timer_unpaid_break', _accumulatedUnpaidMinutes);
    box.put('timer_break_type', _activeBreakType?.index);
    box.put('timer_break_start', _breakStartTime?.millisecondsSinceEpoch);
    box.put('timer_review_end', _reviewEndTime?.millisecondsSinceEpoch);
  }

  void startShift(String jobTypeId) {
    _startTime = DateTime.now();
    _jobTypeId = jobTypeId;
    _isRunning = true;
    _reviewEndTime = null;
    _accumulatedUnpaidMinutes = 0;
    _activeBreakType = null;
    _persistState();
    _startTicker();
    notifyListeners();
  }

  void stopShift() {
    _isRunning = false;
    _reviewEndTime = DateTime.now();
    _ticker?.cancel();
    _persistState();
    NotificationService.cancelNotification(timerNotificationId);
    notifyListeners();
  }

  void resumeShift() {
    _isRunning = true;
    _reviewEndTime = null;
    _persistState();
    _startTicker();
    notifyListeners();
  }

  void resetTimer() {
    _startTime = null;
    _jobTypeId = null;
    _isRunning = false;
    _reviewEndTime = null;
    _activeBreakType = null;
    _accumulatedUnpaidMinutes = 0;
    _ticker?.cancel();
    _elapsed = Duration.zero;
    _persistState();
    NotificationService.cancelNotification(timerNotificationId);
    notifyListeners();
  }

  void toggleBreak(BreakType type, double durationMinutes) {
    if (_activeBreakType == type) {
      endBreak();
    } else {
      startBreak(type, durationMinutes);
    }
  }

  void startBreak(BreakType type, double durationMinutes) {
    _activeBreakType = type;
    _breakStartTime = DateTime.now();
    _totalPaidBreakMinutes = durationMinutes;
    _persistState();
    notifyListeners();
  }

  void endBreak() {
    if (_activeBreakType == BreakType.unpaid && _breakStartTime != null) {
      final diff = DateTime.now().difference(_breakStartTime!).inSeconds / 60.0;
      _accumulatedUnpaidMinutes += diff;
    }
    _activeBreakType = null;
    _breakStartTime = null;
    _persistState();
    notifyListeners();
  }

  void setJobType(String id) {
    _jobTypeId = id;
    _persistState();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateElapsed();
      _updateNotification();
      notifyListeners();
    });
  }

  void _updateElapsed() {
    if (_startTime == null) return;
    final now = _isRunning
        ? DateTime.now()
        : (_reviewEndTime ?? DateTime.now());
    _elapsed = now.difference(_startTime!);

    if (_activeBreakType != null && _breakStartTime != null) {
      final breakElapsed = DateTime.now().difference(_breakStartTime!);
      final totalBreak = Duration(
        seconds: (_totalPaidBreakMinutes * 60).round(),
      );
      _breakRemaining = totalBreak - breakElapsed;
      if (_breakRemaining.isNegative) _breakRemaining = Duration.zero;
    }
  }

  double get netMinutes {
    if (_startTime == null) return 0;
    final now = _isRunning
        ? DateTime.now()
        : (_reviewEndTime ?? DateTime.now());
    double total = now.difference(_startTime!).inSeconds / 60.0;

    double unpaidNow = 0;
    if (_activeBreakType == BreakType.unpaid && _breakStartTime != null) {
      unpaidNow = DateTime.now().difference(_breakStartTime!).inSeconds / 60.0;
    }

    return total - _accumulatedUnpaidMinutes - unpaidNow;
  }

  double calculateLivePay(double hourlyRate) {
    return (netMinutes / 60.0) * hourlyRate;
  }

  double _lastTips = 0;

  double get tips => _lastTips;

  set tips(double val) {
    _lastTips = val;
    notifyListeners();
  }

  Map<String, String>? _lastL10n;

  void updateL10n(Map<String, String> l10n) {
    _lastL10n = l10n;
  }

  void _updateNotification() {
    if (!_isRunning || _startTime == null || _lastL10n == null) return;

    final String title = _activeBreakType != null
        ? (_activeBreakType == BreakType.paid
              ? _lastL10n!['titlePaid']!
              : _lastL10n!['titleUnpaid']!)
        : _lastL10n!['titleActive']!;

    final String body = _activeBreakType != null
        ? _lastL10n!['bodyCountdown']!.replaceAll(
            '[[time]]',
            '${_breakRemaining.inMinutes}:${(_breakRemaining.inSeconds % 60).toString().padLeft(2, '0')}',
          )
        : _lastL10n!['bodyRunning']!;

    NotificationService.showTimerNotification(
      id: timerNotificationId,
      title: title,
      body: body,
      startTime: _startTime!,
      channelName: _lastL10n!['channelName']!,
      channelDescription: _lastL10n!['channelDesc']!,
      stopActionLabel: _lastL10n!['stop']!,
      resumeActionLabel: _lastL10n!['resume']!,
      paidBreakActionLabel: _lastL10n!['paidBreak']!,
      unpaidBreakActionLabel: _lastL10n!['unpaidBreak']!,
      isOnBreak: isOnBreak,
    );
  }
}
