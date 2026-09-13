import 'package:flutter/material.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/services/persistence_service.dart';

class SettingsProvider with ChangeNotifier {
  final PersistenceService _persistence;

  SettingsProvider(this._persistence) {
    _loadSettings();
  }

  ThemeMode _themeMode = ThemeMode.system;
  double _paidBreakDurationMinutes = 20.0;
  double _unpaidBreakDurationMinutes = 45.0;
  bool _hasCompletedOnboarding = false;
  bool _shiftRemindersEnabled = true;
  double _shiftReminderDurationHours = 4.0;
  bool _automaticExpenseEnabled = false;
  List<AutomaticExpense> _defaultAutomaticExpenses = [];

  ThemeMode get themeMode => _themeMode;

  double get paidBreakDurationMinutes => _paidBreakDurationMinutes;

  double get unpaidBreakDurationMinutes => _unpaidBreakDurationMinutes;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  bool get shiftRemindersEnabled => _shiftRemindersEnabled;

  double get shiftReminderDurationHours => _shiftReminderDurationHours;

  bool get automaticExpenseEnabled => _automaticExpenseEnabled;

  List<AutomaticExpense> get defaultAutomaticExpenses =>
      _defaultAutomaticExpenses;

  void _loadSettings() {
    final box = _persistence.settingsBox;
    _themeMode = ThemeMode
        .values[box.get('themeMode', defaultValue: ThemeMode.system.index)];
    _paidBreakDurationMinutes = box.get(
      'paidBreakDurationMinutes',
      defaultValue: 20.0,
    );
    _unpaidBreakDurationMinutes = box.get(
      'unpaidBreakDurationMinutes',
      defaultValue: 45.0,
    );
    _hasCompletedOnboarding = box.get(
      'hasCompletedOnboarding',
      defaultValue: false,
    );
    _shiftRemindersEnabled = box.get(
      'shiftRemindersEnabled',
      defaultValue: true,
    );
    _shiftReminderDurationHours = box.get(
      'shiftReminderDurationHours',
      defaultValue: 4.0,
    );
    _automaticExpenseEnabled = box.get(
      'automaticExpenseEnabled',
      defaultValue: false,
    );

    final List? storedExpenses = box.get('defaultAutomaticExpenses');
    if (storedExpenses != null) {
      _defaultAutomaticExpenses = List<AutomaticExpense>.from(storedExpenses);
    } else {
      _defaultAutomaticExpenses = [];
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _persistence.settingsBox.put('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setShiftRemindersEnabled(bool enabled) async {
    _shiftRemindersEnabled = enabled;
    await _persistence.settingsBox.put('shiftRemindersEnabled', enabled);
    notifyListeners();
  }

  Future<void> setShiftReminderDurationHours(double hours) async {
    _shiftReminderDurationHours = hours;
    await _persistence.settingsBox.put('shiftReminderDurationHours', hours);
    notifyListeners();
  }

  Future<void> setBreakDurations(double paid, double unpaid) async {
    _paidBreakDurationMinutes = paid;
    _unpaidBreakDurationMinutes = unpaid;
    await _persistence.settingsBox.put('paidBreakDurationMinutes', paid);
    await _persistence.settingsBox.put('unpaidBreakDurationMinutes', unpaid);
    notifyListeners();
  }

  Future<void> setAutomaticExpenseEnabled(bool enabled) async {
    _automaticExpenseEnabled = enabled;
    await _persistence.settingsBox.put('automaticExpenseEnabled', enabled);
    notifyListeners();
  }

  Future<void> updateDefaultAutomaticExpenses(
    List<AutomaticExpense> expenses,
  ) async {
    _defaultAutomaticExpenses = expenses;
    await _persistence.settingsBox.put('defaultAutomaticExpenses', expenses);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasCompletedOnboarding = true;
    await _persistence.settingsBox.put('hasCompletedOnboarding', true);
    notifyListeners();
  }

  Future<void> resetAllSettings() async {
    _themeMode = ThemeMode.system;
    _paidBreakDurationMinutes = 20.0;
    _unpaidBreakDurationMinutes = 45.0;
    _hasCompletedOnboarding = false;
    _shiftRemindersEnabled = true;
    _shiftReminderDurationHours = 4.0;
    _automaticExpenseEnabled = false;
    _defaultAutomaticExpenses = [];
    notifyListeners();
  }
}
