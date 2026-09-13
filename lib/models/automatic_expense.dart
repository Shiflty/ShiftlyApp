import 'package:hive/hive.dart';

part 'automatic_expense.g.dart';

@HiveType(typeId: 5)
class AutomaticExpense extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  AutomaticExpense({required this.description, required this.amount});

  AutomaticExpense copyWith({String? description, double? amount}) {
    return AutomaticExpense(
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }
}
