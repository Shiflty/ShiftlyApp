import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
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
      _autoDescControllers.add(TextEditingController(text: ''));
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
    final l = AppLocalizations.of(context)!;
    List<AutomaticExpense> expenses = [];
    for (int i = 0; i < _autoAmountControllers.length; i++) {
      final amountText = _autoAmountControllers[i].text.trim();
      final desc = _autoDescControllers[i].text.trim();

      if (amountText.isEmpty && desc.isEmpty) continue;

      final amount = double.tryParse(amountText);
      if (desc.isEmpty) {
        UIUtils.showSnackBar(
          context,
          l.settings_dialog_error_enter_desc,
          isError: true,
        );
        return;
      }
      if (amount == null || amount <= 0) {
        UIUtils.showSnackBar(
          context,
          l.onboarding_auto_expenses_invalid_amount,
          isError: true,
        );
        return;
      }
      expenses.add(AutomaticExpense(description: desc, amount: amount));
    }
    await settings.updateDefaultAutomaticExpenses(expenses);
    if (mounted) {
      UIUtils.showSnackBar(context, l.expenses_auto_updated_msg);
    }
  }

  void _showExpenseDialog(BuildContext context, [Expense? expense]) {
    final settings = context.read<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
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
          title: Text(
            expense == null
                ? l.expenses_dialog_add_title
                : l.expenses_dialog_edit_title,
          ),
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
                  decoration: InputDecoration(
                    labelText: l.onboarding_auto_expenses_desc_label,
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: '${l.expenses_total_label} ($symbol)',
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
              child: Text(l.common_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final desc = descriptionController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0.0;

                if (desc.isEmpty) {
                  UIUtils.showSnackBar(
                    context,
                    l.settings_dialog_error_enter_desc,
                    isError: true,
                  );
                  return;
                }

                if (amount <= 0) {
                  UIUtils.showSnackBar(
                    context,
                    l.onboarding_auto_expenses_invalid_amount,
                    isError: true,
                  );
                  return;
                }

                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: expense == null
                      ? l.expenses_dialog_add_title
                      : l.expenses_dialog_edit_title,
                  content: l.expenses_save_expense_confirm_content
                      .replaceAll('[[desc]]', desc)
                      .replaceAll(
                        '[[amount]]',
                        UIUtils.formatCurrency(amount, symbol: symbol),
                      ),
                  cancelLabel: l.common_cancel,
                  confirmLabel: l.common_save,
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
              child: Text(l.common_save),
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
    final l = AppLocalizations.of(context)!;
    final groupedExpenses = shiftProvider.expensesGroupedByMonth;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.expenses_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              _buildSectionHeader(context, l.expenses_auto_section_title),
              const SizedBox(height: AppTheme.spaceXs),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceSm),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l.expenses_auto_section_enable),
                        subtitle: Text(l.expenses_auto_section_subtitle),
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
                          label: Text(l.expenses_action_add_auto),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveDefaultExpenses,
                            child: Text(l.expenses_action_update_settings),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              _buildSectionHeader(context, l.expenses_history_section_title),
              const SizedBox(height: AppTheme.spaceXs),
              if (groupedExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(l.home_shift_list_no_shifts),
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
        label: Text(l.expenses_action_new_expense),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildAutoExpenseRow(int index, String symbol) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _autoDescControllers[index],
              decoration: InputDecoration(
                labelText: l.onboarding_auto_expenses_desc_label,
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
    final settings = context.watch<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
    final date = DateTime.parse("$monthKey-01");
    final monthName = DateFormat.MMMM(l.localeName).format(date);
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
                '${l.expenses_total_label}: ${UIUtils.formatCurrency(total, symbol: symbol)}',
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
    final l = AppLocalizations.of(context)!;
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
        title: l.expenses_dialog_delete_title,
        content: l.expenses_delete_expense_confirm_content
            .replaceAll('[[desc]]', expense.description)
            .replaceAll(
              '[[amount]]',
              UIUtils.formatCurrency(expense.amount, symbol: symbol),
            ),
        isDestructive: true,
        confirmLabel: l.common_delete,
        cancelLabel: l.common_cancel,
      ),
      onDismissed: (_) {
        shiftProvider.deleteExpense(expense.id);
        UIUtils.showSnackBar(
          context,
          l.expenses_deleted_msg,
          action: SnackBarAction(
            label: l.common_cancel,
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
