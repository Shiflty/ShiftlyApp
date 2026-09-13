import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/models/automatic_expense.dart';
import 'package:shiftly/models/expense.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:uuid/uuid.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<TextEditingController> _autoAmountControllers = [];
  final List<TextEditingController> _autoDescControllers = [];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    for (var e in settings.defaultAutomaticExpenses) {
      _autoAmountControllers.add(
        TextEditingController(text: e.amount.toStringAsFixed(0)),
      );
      _autoDescControllers.add(TextEditingController(text: e.description));
    }
    if (_autoAmountControllers.isEmpty) {
      _autoAmountControllers.add(TextEditingController(text: '0'));
      _autoDescControllers.add(TextEditingController(text: 'נסיעות'));
    }
  }

  @override
  void dispose() {
    for (var c in _autoAmountControllers) {
      c.dispose();
    }
    for (var c in _autoDescControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveDefaultExpenses() async {
    final settings = context.read<SettingsProvider>();
    List<AutomaticExpense> expenses = [];
    for (int i = 0; i < _autoAmountControllers.length; i++) {
      final amountText = _autoAmountControllers[i].text.trim();
      final desc = _autoDescControllers[i].text.trim();

      if (amountText.isEmpty && desc.isEmpty) continue;

      final amount = double.tryParse(amountText);
      if (desc.isEmpty) {
        UIUtils.showSnackBar(
          context,
          'נא להזין תיאור לכל ההוצאות הקבועות',
          isError: true,
        );
        return;
      }
      if (amount == null || amount <= 0) {
        UIUtils.showSnackBar(
          context,
          'סכום ההוצאה "$desc" חייב להיות מספר גדול מ-0',
          isError: true,
        );
        return;
      }
      expenses.add(AutomaticExpense(description: desc, amount: amount));
    }
    await settings.updateDefaultAutomaticExpenses(expenses);
    if (mounted) {
      UIUtils.showSnackBar(context, 'הגדרות הוצאות אוטומטיות עודכנו');
    }
  }

  void _showExpenseDialog(BuildContext context, [Expense? expense]) {
    final symbol = context.read<SettingsProvider>().currencySymbol;
    final descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    final amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    DateTime selectedDate = expense?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(expense == null ? 'הוספת הוצאה' : 'עריכת הוצאה'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue,
                  ),
                  title: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'תיאור ההוצאה (למשל: אוטובוס)',
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'סכום ($symbol)',
                    prefixIcon: const Icon(Icons.sell_rounded),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ביטול'),
            ),
            ElevatedButton(
              onPressed: () async {
                final desc = descriptionController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0.0;

                if (desc.isEmpty) {
                  UIUtils.showSnackBar(
                    context,
                    'נא להזין תיאור להוצאה',
                    isError: true,
                  );
                  return;
                }

                if (amount <= 0) {
                  UIUtils.showSnackBar(
                    context,
                    'סכום ההוצאה חייב להיות גדול מ-0',
                    isError: true,
                  );
                  return;
                }

                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: expense == null ? 'הוספת הוצאה' : 'עדכון הוצאה',
                  content:
                      'האם לשמור את ההוצאה "$desc" בסך ${UIUtils.formatCurrency(amount, symbol: symbol)}?',
                );

                if (confirmed != true || !context.mounted) return;

                final provider = context.read<ShiftProvider>();
                if (expense == null) {
                  provider.addExpense(
                    Expense(
                      id: const Uuid().v4(),
                      date: selectedDate,
                      description: desc,
                      amount: amount,
                    ),
                  );
                } else {
                  expense.description = desc;
                  expense.amount = amount;
                  expense.date = selectedDate;
                  provider.updateExpense(expense);
                }
                Navigator.pop(ctx);
              },
              child: const Text('שמור'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final settings = context.watch<SettingsProvider>();
    final groupedExpenses = shiftProvider.expensesGroupedByMonth;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ניהול הוצאות',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceSm,
            AppTheme.spaceXs,
            AppTheme.spaceSm,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, 'הוצאות קבועות למשמרת'),
              const SizedBox(height: AppTheme.spaceXs),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceSm),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('הוצאות אוטומטיות'),
                        subtitle: const Text(
                          'הוסף הוצאות קבועות לכל משמרת חדשה',
                        ),
                        secondary: const Icon(
                          Icons.auto_fix_high_rounded,
                          color: AppTheme.primaryDark,
                        ),
                        value: settings.automaticExpenseEnabled,
                        onChanged: (val) =>
                            settings.setAutomaticExpenseEnabled(val),
                        activeThumbColor: AppTheme.primaryDark,
                        activeTrackColor: AppTheme.primary.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      if (settings.automaticExpenseEnabled) ...[
                        const Divider(height: AppTheme.spaceLg),
                        ...List.generate(
                          _autoAmountControllers.length,
                          (index) => _buildAutoExpenseRow(
                            index,
                            settings.currencySymbol,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _autoAmountControllers.add(
                              TextEditingController(text: '0'),
                            );
                            _autoDescControllers.add(
                              TextEditingController(text: ''),
                            );
                          }),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('הוסף הוצאה קבועה'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveDefaultExpenses,
                            child: const Text('עדכן הגדרות'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              _buildSectionHeader(context, 'פירוט הוצאות חודשי'),
              const SizedBox(height: AppTheme.spaceXs),
              if (groupedExpenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('אין הוצאות רשומות'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedExpenses.length,
                  itemBuilder: (context, index) {
                    final monthKey = groupedExpenses.keys.elementAt(index);
                    final expenses = groupedExpenses[monthKey]!;
                    return _MonthExpenseSection(
                      monthKey: monthKey,
                      expenses: expenses,
                      onEdit: (e) => _showExpenseDialog(context, e),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseDialog(context),
        backgroundColor: AppTheme.expenseSoft,
        foregroundColor: Colors.white,
        label: const Text('הוצאה חדשה'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildAutoExpenseRow(int index, String symbol) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _autoDescControllers[index],
              decoration: const InputDecoration(
                labelText: 'תיאור',
                hintText: 'למשל: נסיעות',
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
              icon: const Icon(
                Icons.remove_circle_outline,
                color: AppTheme.expense,
              ),
              onPressed: () => setState(() {
                _autoAmountControllers.removeAt(index);
                _autoDescControllers.removeAt(index);
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _MonthExpenseSection extends StatelessWidget {
  final String monthKey;
  final List<Expense> expenses;
  final Function(Expense) onEdit;

  const _MonthExpenseSection({
    required this.monthKey,
    required this.expenses,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = context.watch<SettingsProvider>().currencySymbol;
    final date = DateTime.parse("$monthKey-01");
    final monthName = DateFormat.MMMM('he_IL').format(date);
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$monthName ${date.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
              Text(
                'סה"כ: ${UIUtils.formatCurrency(total, symbol: symbol)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.expenseSoft,
                ),
              ),
            ],
          ),
        ),
        ...expenses.map(
          (e) =>
              _ExpenseTile(expense: e, onEdit: () => onEdit(e), symbol: symbol),
        ),
        const Divider(),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final String symbol;

  const _ExpenseTile({
    required this.expense,
    required this.onEdit,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.read<ShiftProvider>();
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.expense.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppTheme.spaceMd),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: AppTheme.expenseSoft,
        ),
      ),
      confirmDismiss: (direction) async => await UIUtils.showConfirmDialog(
        context: context,
        title: 'מחיקת הוצאה',
        content:
            'האם למחוק את "${expense.description}" בסך ${UIUtils.formatCurrency(expense.amount, symbol: symbol)}?',
        isDestructive: true,
        confirmLabel: 'מחק',
      ),
      onDismissed: (_) {
        shiftProvider.deleteExpense(expense.id);
        UIUtils.showSnackBar(
          context,
          'הוצאה נמחקה',
          action: SnackBarAction(
            label: 'ביטול',
            onPressed: () => shiftProvider.addExpense(expense),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: onEdit,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.expense.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.money_off_rounded,
              color: AppTheme.expenseSoft,
              size: 20,
            ),
          ),
          title: Text(
            expense.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(expense.date)),
          trailing: Text(
            UIUtils.formatCurrency(expense.amount, symbol: symbol),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.expenseSoft,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
