class ShiftFilter {
  final double? minWage;
  final double? maxWage;
  final double? minTips;
  final double? maxTips;
  final double? minExpenses;
  final double? maxExpenses;
  final double? minDuration;
  final double? maxDuration;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? jobTypeId;

  ShiftFilter({
    this.minWage,
    this.maxWage,
    this.minTips,
    this.maxTips,
    this.minExpenses,
    this.maxExpenses,
    this.minDuration,
    this.maxDuration,
    this.startDate,
    this.endDate,
    this.jobTypeId,
  });

  bool get isActive =>
      minWage != null ||
      maxWage != null ||
      minTips != null ||
      maxTips != null ||
      minExpenses != null ||
      maxExpenses != null ||
      minDuration != null ||
      maxDuration != null ||
      startDate != null ||
      endDate != null ||
      jobTypeId != null;

  ShiftFilter copyWith({
    double? minWage,
    double? maxWage,
    double? minTips,
    double? maxTips,
    double? minExpenses,
    double? maxExpenses,
    double? minDuration,
    double? maxDuration,
    DateTime? startDate,
    DateTime? endDate,
    String? jobTypeId,
    bool clearMinWage = false,
    bool clearMaxWage = false,
    bool clearMinTips = false,
    bool clearMaxTips = false,
    bool clearMinExpenses = false,
    bool clearMaxExpenses = false,
    bool clearMinDuration = false,
    bool clearMaxDuration = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearJobTypeId = false,
  }) {
    return ShiftFilter(
      minWage: clearMinWage ? null : minWage ?? this.minWage,
      maxWage: clearMaxWage ? null : maxWage ?? this.maxWage,
      minTips: clearMinTips ? null : minTips ?? this.minTips,
      maxTips: clearMaxTips ? null : maxTips ?? this.maxTips,
      minExpenses: clearMinExpenses ? null : minExpenses ?? this.minExpenses,
      maxExpenses: clearMaxExpenses ? null : maxExpenses ?? this.maxExpenses,
      minDuration: clearMinDuration ? null : minDuration ?? this.minDuration,
      maxDuration: clearMaxDuration ? null : maxDuration ?? this.maxDuration,
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      jobTypeId: clearJobTypeId ? null : jobTypeId ?? this.jobTypeId,
    );
  }
}
