import 'package:hive/hive.dart';

part 'wage_entry.g.dart';

@HiveType(typeId: 4)
class WageEntry extends HiveObject {
  @HiveField(0)
  DateTime startDate;

  @HiveField(1)
  double hourlyRate;

  WageEntry({required this.startDate, required this.hourlyRate});

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'hourlyRate': hourlyRate,
  };

  factory WageEntry.fromJson(Map<String, dynamic> json) => WageEntry(
    startDate: DateTime.parse(json['startDate']),
    hourlyRate: json['hourlyRate'].toDouble(),
  );
}
