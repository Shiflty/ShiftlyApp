import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shiftly/l10n/app_localizations.dart';
import 'package:shiftly/models/job_type.dart';
import 'package:shiftly/models/wage_entry.dart';
import 'package:shiftly/providers/auth_provider.dart';
import 'package:shiftly/providers/settings_provider.dart';
import 'package:shiftly/providers/shift_provider.dart';
import 'package:shiftly/screens/auth_screen.dart';
import 'package:shiftly/services/notification_service.dart';
import 'package:shiftly/theme/app_theme.dart';
import 'package:shiftly/utils/ui_utils.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _paidController;
  late TextEditingController _unpaidController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _paidController = TextEditingController(
      text: settings.paidBreakDurationMinutes.toStringAsFixed(0),
    );
    _unpaidController = TextEditingController(
      text: settings.unpaidBreakDurationMinutes.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _paidController.dispose();
    _unpaidController.dispose();
    super.dispose();
  }

  void _showEditJobDialog(BuildContext context, [JobType? job]) {
    final settings = context.read<SettingsProvider>();
    final symbol = settings.currencySymbol;
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: job?.name ?? '');
    final rateController = TextEditingController(
      text: (job?.hourlyRate ?? 40.22).toString(),
    );
    DateTime effectiveDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            job == null
                ? l.onboarding_job_types_add_button
                : l.onboarding_job_types_edit_button,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l.onboarding_auto_expenses_desc_label,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                TextField(
                  controller: rateController,
                  decoration: InputDecoration(
                    labelText: l.onboarding_auto_expenses_amount_label,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppTheme.spaceSm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l.add_shift_manual_date_label,
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(effectiveDate),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded, size: 20),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: effectiveDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => effectiveDate = picked);
                    }
                  },
                ),
                if (job != null &&
                    job.wageHistory != null &&
                    job.wageHistory!.isNotEmpty) ...[
                  const Divider(height: AppTheme.spaceLg),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l.settings_wage_history_title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  _WageTimeline(
                    entries: job.wageHistory!,
                    compact: true,
                    maxItems: 4,
                    symbol: symbol,
                  ),
                ],
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
                final provider = context.read<ShiftProvider>();
                final name = nameController.text.trim();
                final rate = double.tryParse(rateController.text) ?? 0.0;

                if (name.isEmpty) {
                  UIUtils.showSnackBar(
                    context,
                    l.settings_dialog_error_enter_desc, // Better key?
                    isError: true,
                  );
                  return;
                }

                final exists = provider.jobTypes.any(
                  (j) =>
                      j.name.toLowerCase() == name.toLowerCase() &&
                      j.id != job?.id,
                );

                if (exists) {
                  UIUtils.showSnackBar(
                    context,
                    l.onboarding_job_types_same,
                    isError: true,
                  );
                  return;
                }

                if (rate < 0) {
                  UIUtils.showSnackBar(context, l.common_error, isError: true);
                  return;
                }

                final confirmed = await UIUtils.showConfirmDialog(
                  context: context,
                  title: job == null ? l.common_confirm : l.common_save,
                  content: '${l.common_save} $name?',
                );

                if (confirmed != true) return;
                if (!context.mounted) return;

                if (job == null) {
                  final newJob = JobType(
                    id: const Uuid().v4(),
                    name: name,
                    hourlyRate: rate,
                    wageHistory: [
                      WageEntry(startDate: effectiveDate, hourlyRate: rate),
                    ],
                  );
                  newJob.syncCurrentRate();
                  provider.addJobType(newJob);
                } else {
                  job.name = name;
                  job.wageHistory ??= [];
                  job.wageHistory!.removeWhere(
                    (e) =>
                        e.startDate.year == effectiveDate.year &&
                        e.startDate.month == effectiveDate.month &&
                        e.startDate.day == effectiveDate.day,
                  );
                  job.wageHistory!.add(
                    WageEntry(startDate: effectiveDate, hourlyRate: rate),
                  );
                  job.wageHistory!.sort(
                    (a, b) => a.startDate.compareTo(b.startDate),
                  );
                  job.syncCurrentRate();
                  await provider.updateJobType(job);
                }
                if (context.mounted) Navigator.pop(ctx);
              },
              child: Text(l.common_save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteJob(BuildContext context, JobType job) async {
    final provider = context.read<ShiftProvider>();
    final name = job.name;
    final l = AppLocalizations.of(context)!;

    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.common_delete,
      content: '${l.common_delete} $name?',
      isDestructive: true,
      confirmLabel: l.common_delete,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    provider.deleteJobType(job.id);

    UIUtils.showSnackBar(
      context,
      '$name ${l.common_delete}',
      action: SnackBarAction(
        label: l.common_back,
        onPressed: () {
          provider.addJobType(job);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final symbol = settings.currencySymbol;
    final rawJobs = context.watch<ShiftProvider>().jobTypes;
    final l = AppLocalizations.of(context)!;

    final jobs = List<JobType>.from(rawJobs)
      ..sort((a, b) {
        if (a.id == '1') return -1;
        if (b.id == '1') return 1;
        if (a.id == '2') return -1;
        if (b.id == '2') return 1;
        return a.name.compareTo(b.name);
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.settings_title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceSm,
            AppTheme.spaceSm,
            AppTheme.spaceSm,
            120, // Increased for ad space and system navigation
          ),
          children: [
            _buildSectionHeader(context, l.settings_user_details_title),
            const SizedBox(height: AppTheme.spaceXs),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryDark),
                    title: Text(l.settings_user_name),
                    subtitle: Text(auth.userName ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: AppTheme.primaryDark),
                    title: Text(l.settings_user_email),
                    subtitle: Text(auth.userEmail ?? ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSectionHeader(context, l.settings_section_app),
            const SizedBox(height: AppTheme.spaceXs),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l.settings_field_notifications),
                    subtitle: Text(l.settings_field_notifications_sub),
                    secondary: Icon(
                      Icons.notifications_active_outlined,
                      color: AppTheme.primaryDark,
                    ),
                    value: settings.shiftRemindersEnabled,
                    onChanged: (val) async {
                      await settings.setShiftRemindersEnabled(val);
                      if (val) {
                        await NotificationService.requestPermissions();
                      }
                      if (!context.mounted) return;
                      context.read<ShiftProvider>().refreshAllReminders({
                        'title': l.notification_reminder_title,
                        'body': l.notification_reminder_body,
                        'hours': l.common_hours_suffix,
                        'minutes': l.common_min_suffix,
                        'channelName': l.notification_channel_reminders_name,
                        'channelDesc': l.notification_channel_reminders_desc,
                      });
                    },
                    activeThumbColor: AppTheme.primaryDark,
                    activeTrackColor: AppTheme.primary.withValues(alpha: 0.35),
                  ),
                  const Divider(height: 1, indent: 56),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.settings_field_theme,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text(l.settings_theme_system),
                              icon: const Icon(Icons.brightness_auto_rounded),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text(l.settings_theme_light),
                              icon: const Icon(Icons.light_mode_rounded),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text(l.settings_theme_dark),
                              icon: const Icon(Icons.dark_mode_rounded),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (val) =>
                              settings.setThemeMode(val.first),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    title: Text(l.settings_field_language),
                    leading: const Icon(
                      Icons.language_rounded,
                      color: AppTheme.primaryDark,
                    ),
                    trailing: DropdownButton<String>(
                      value: settings.locale.languageCode,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: 'he',
                          child: Text(l.settings_language_he),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(l.settings_language_en),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          settings.setLocale(Locale(val));
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    title: Text(l.settings_field_currency),
                    subtitle: Text(l.settings_field_currency_sub),
                    leading: const Icon(
                      Icons.payments_outlined,
                      color: AppTheme.primaryDark,
                    ),
                    trailing: DropdownButton<String>(
                      value: settings.currencySymbol,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: '₪', child: Text('₪ ILS')),
                        DropdownMenuItem(value: '\$', child: Text('\$ USD')),
                        DropdownMenuItem(value: '€', child: Text('€ EUR')),
                        DropdownMenuItem(value: '£', child: Text('£ GBP')),
                      ],
                      onChanged: (val) {
                        if (val != null) settings.setCurrencySymbol(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (settings.shiftRemindersEnabled) ...[
              const SizedBox(height: AppTheme.spaceLg),
              _buildSectionHeader(context, l.settings_section_reminders),
              const SizedBox(height: AppTheme.spaceXs),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceSm),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l.settings_field_reminder_time,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${(settings.shiftReminderDurationHours * 10).round() / 10} ${l.common_hours_suffix}'
                                .replaceAll('.0 ', ' '),
                            style: const TextStyle(
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: settings.shiftReminderDurationHours,
                        min: 0.5,
                        max: 24,
                        divisions: 47,
                        onChanged: (val) async {
                          await settings.setShiftReminderDurationHours(val);
                          if (!context.mounted) return;
                          context.read<ShiftProvider>().refreshAllReminders({
                            'title': l.notification_reminder_title,
                            'body': l.notification_reminder_body,
                            'hours': l.common_hours_suffix,
                            'minutes': l.common_min_suffix,
                            'channelName':
                                l.notification_channel_reminders_name,
                            'channelDesc':
                                l.notification_channel_reminders_desc,
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spaceLg),
            _buildSectionHeader(context, l.settings_section_breaks),
            const SizedBox(height: AppTheme.spaceXs),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l.settings_field_breaks_enabled,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(l.settings_field_breaks_enabled_sub),
                      secondary: const Icon(
                        Icons.timer_off_outlined,
                        color: AppTheme.primaryDark,
                      ),
                      value: settings.breaksEnabled,
                      onChanged: (val) => settings.setBreaksEnabled(val),
                      activeThumbColor: AppTheme.primaryDark,
                      activeTrackColor: AppTheme.primary.withValues(
                        alpha: 0.35,
                      ),
                    ),
                    if (settings.breaksEnabled) ...[
                      const Divider(height: 16),
                      TextField(
                        controller: _paidController,
                        decoration: InputDecoration(
                          labelText: l.settings_field_paid_break,
                          prefixIcon: const Icon(Icons.timer_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      TextField(
                        controller: _unpaidController,
                        decoration: InputDecoration(
                          labelText: l.settings_field_unpaid_break,
                          prefixIcon: const Icon(Icons.coffee_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final paid =
                                double.tryParse(_paidController.text) ?? 20.0;
                            final unpaid =
                                double.tryParse(_unpaidController.text) ?? 45.0;

                            final confirmed = await UIUtils.showConfirmDialog(
                              context: context,
                              title: l.settings_dialog_update_breaks_title,
                              content:
                                  '${l.settings_dialog_update_breaks_title}?',
                            );

                            if (confirmed != true) return;
                            if (!context.mounted) return;

                            settings.setBreakDurations(paid, unpaid);
                            UIUtils.showSnackBar(context, l.common_success);
                          },
                          child: Text(l.settings_action_update_breaks),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Row(
              children: [
                Expanded(
                  child: _buildSectionHeader(
                    context,
                    l.onboarding_job_types_title,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditJobDialog(context),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l.common_confirm),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceXs),
            if (rawJobs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Center(
                  child: Text(
                    l.common_error,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              )
            else
              ...jobs.map(
                (job) => _JobCard(
                  job: job,
                  onEdit: () => _showEditJobDialog(context, job),
                  onDelete: () => _deleteJob(context, job),
                  symbol: symbol,
                ),
              ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSectionHeader(context, l.settings_section_account),
            const SizedBox(height: AppTheme.spaceXs),
            Card(
              child: ListTile(
                title: Text(
                  l.settings_logout_title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(l.settings_logout_subtitle),
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppTheme.primaryDark,
                ),
                onTap: () async {
                  final confirmed = await UIUtils.showConfirmDialog(
                    context: context,
                    title: l.settings_logout_dialog_title,
                    content: l.settings_logout_confirm_content,
                    confirmLabel: l.settings_logout_confirm_button,
                    isDestructive: true,
                  );

                  if (confirmed == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            _buildSectionHeader(context, l.settings_section_danger),
            const SizedBox(height: AppTheme.spaceXs),
            Card(
              child: ListTile(
                title: Text(
                  l.settings_action_factory_reset,
                  style: const TextStyle(
                    color: AppTheme.expense,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(l.settings_action_factory_reset_sub),
                trailing: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppTheme.expense,
                ),
                onTap: () => _handleFactoryReset(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final l = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: auth.userName);
    final emailController = TextEditingController(text: auth.userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settings_user_edit_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l.settings_user_name),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: l.settings_user_email),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.common_cancel)),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<AuthProvider>().updateProfile(
                  nameController.text.trim(),
                  emailController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  UIUtils.showSnackBar(context, l.settings_user_update_success);
                }
              } catch (e) {
                if (context.mounted) UIUtils.showSnackBar(context, l.common_error, isError: true);
              }
            },
            child: Text(l.common_save),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFactoryReset(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    // Step 1: First Confirmation
    final confirmed = await UIUtils.showConfirmDialog(
      context: context,
      title: l.settings_dialog_factory_reset_title,
      content: l.settings_dialog_factory_reset_content,
      confirmLabel: l.common_continue,
      isDestructive: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Step 2: Second Confirmation (Manual Input or special warning)
    final finalConfirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.expense),
            const SizedBox(width: 8),
            Text(l.settings_dialog_final_confirm_title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.settings_dialog_final_confirm_content_1),
            const SizedBox(height: 16),
            Text(
              l.settings_dialog_final_confirm_content_2,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l.common_cancel,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expense,
              foregroundColor: Colors.white,
            ),
            child: Text(l.settings_dialog_final_confirm_button),
          ),
        ],
      ),
    );

    if (finalConfirm != true) return;
    if (!context.mounted) return;

    // Perform Reset
    final shiftProvider = context.read<ShiftProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await shiftProvider.factoryReset();
    await settingsProvider.resetAllSettings();

    if (!context.mounted) return;

    UIUtils.showSnackBar(context, l.common_success);

    // Navigate to Splash or Onboarding
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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

class _JobCard extends StatelessWidget {
  final JobType job;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String symbol;

  const _JobCard({
    required this.job,
    required this.onEdit,
    required this.onDelete,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final currentRate = job.getRateForDate(DateTime.now());
    final history = List<WageEntry>.from(job.wageHistory ?? const [])
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppTheme.iconForJobName(job.name),
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${UIUtils.formatCurrency(currentRate, symbol: symbol)} ${l.onboarding_job_types_rate_suffix}',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l.common_save,
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: AppTheme.primaryDark,
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: l.common_delete,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.expense,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
              if (history.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceSm),
                const Divider(height: 1),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  l.settings_wage_history_title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 12),
                _WageTimeline(entries: history, symbol: symbol),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WageTimeline extends StatelessWidget {
  final List<WageEntry> entries;
  final bool compact;
  final int? maxItems;
  final String symbol;

  const _WageTimeline({
    required this.entries,
    this.compact = false,
    this.maxItems,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List<WageEntry>.from(entries)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final items = maxItems != null ? sorted.take(maxItems!).toList() : sorted;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Column(
      children: List.generate(items.length, (index) {
        final entry = items[index];
        final isFirst = index == 0;
        final isLast = index == items.length - 1;

        double? delta;
        if (index < items.length - 1) {
          delta = entry.hourlyRate - items[index + 1].hourlyRate;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: isFirst ? 12 : 10,
                      height: isFirst ? 12 : 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFirst
                            ? AppTheme.primary
                            : AppTheme.primary.withValues(alpha: 0.45),
                        border: Border.all(
                          color:
                              Theme.of(context).cardTheme.color ??
                              (isDark ? AppTheme.darkCard : Colors.white),
                          width: 2,
                        ),
                        boxShadow: isFirst
                            ? [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(1),
                            color: AppTheme.primary.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : (compact ? 10 : 14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(entry.startDate),
                              style: TextStyle(
                                fontSize: compact ? 12 : 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            if (isFirst && !compact)
                              Text(
                                l.settings_current_rate,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        UIUtils.formatCurrency(
                          entry.hourlyRate,
                          symbol: symbol,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 13 : 15,
                          color: isFirst
                              ? AppTheme.primaryDark
                              : Theme.of(context).colorScheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (delta != null && delta != 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (delta > 0 ? AppTheme.profit : AppTheme.expense)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: delta > 0
                                  ? AppTheme.profitSoft
                                  : AppTheme.expenseSoft,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
