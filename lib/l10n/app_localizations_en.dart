// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_app_name => 'Shiftly';

  @override
  String get common_continue => 'Continue';

  @override
  String get common_back => 'Back';

  @override
  String get common_start => 'Let\'s Start!';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_add => 'Add';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_calendar_title => 'Shift Calendar';

  @override
  String get common_tagline => 'Smart Work Tracker';

  @override
  String get common_hours_suffix => 'hours';

  @override
  String get common_min_suffix => 'min';

  @override
  String get common_net => 'Net';

  @override
  String get common_shifts_count => 'Shifts';

  @override
  String get common_delete_shit_short => 'Delete Shift';

  @override
  String get common_delete_shit_expanded =>
      'Are you sure you want to delete the shift from ';

  @override
  String get common_delete_shift_after => 'Shift deleted successfully';

  @override
  String get common_save_and_finish => 'Save & Finish';

  @override
  String get common_reset => 'Reset';

  @override
  String get common_reset_and_cancel => 'Cancel & Reset';

  @override
  String get common_undo => 'Undo';

  @override
  String get onboarding_welcome_title => 'Welcome to Shiftly';

  @override
  String get onboarding_welcome_subtitle =>
      'The app that helps you track your shifts, salary, and tips easily and accurately.';

  @override
  String get onboarding_welcome_description =>
      'Let\'s set up some basics to get started.';

  @override
  String get onboarding_language_title => 'App Language';

  @override
  String get onboarding_language_subtitle => 'Choose your preferred language.';

  @override
  String get onboarding_currency_title => 'Select Currency';

  @override
  String get onboarding_currency_subtitle =>
      'Which currency would you like to use for salary and expenses?';

  @override
  String get onboarding_breaks_title => 'Break Settings';

  @override
  String get onboarding_breaks_subtitle =>
      'How long does a break usually last?';

  @override
  String get onboarding_breaks_enable => 'Enable Breaks';

  @override
  String get onboarding_breaks_paid_label => 'Paid Break (minutes)';

  @override
  String get onboarding_breaks_unpaid_label => 'Unpaid Break (minutes)';

  @override
  String get onboarding_reminders_title => 'Shift Reminders';

  @override
  String get onboarding_reminders_subtitle =>
      'Would you like to get a reminder before your shift starts?';

  @override
  String get onboarding_reminders_enable => 'Enable Reminders';

  @override
  String get onboarding_reminders_time_label => 'How long before? (hours)';

  @override
  String get onboarding_reminders_hours => 'hours';

  @override
  String get onboarding_auto_expenses_title => 'Recurring Expenses';

  @override
  String get onboarding_auto_expenses_subtitle =>
      'Do you have recurring expenses in every shift? (e.g. travel)';

  @override
  String get onboarding_auto_expenses_enable => 'Enable Auto Expenses';

  @override
  String get onboarding_auto_expenses_add_button => 'Add Expense';

  @override
  String get onboarding_auto_expenses_desc_label => 'Description';

  @override
  String get onboarding_auto_expenses_amount_label => '\$';

  @override
  String get onboarding_auto_expenses_invalid_amount =>
      'Expense amount must be greater than 0';

  @override
  String get onboarding_job_types_title => 'Shifts & Wages';

  @override
  String get onboarding_job_types_subtitle =>
      'Define your different roles and hourly rates.';

  @override
  String get onboarding_job_types_add_button => 'Add Shift Type';

  @override
  String get onboarding_job_types_edit_button => 'Edit Shift Type';

  @override
  String get onboarding_job_types_delete_title => 'Delete Job';

  @override
  String get onboarding_job_types_delete_desc => 'Delete job ';

  @override
  String get onboarding_job_types_rate_suffix => 'per hour';

  @override
  String get onboarding_job_types_same => 'Job with this name already exists';

  @override
  String get default_job_buffet => 'Buffet';

  @override
  String get default_job_steward => 'Steward';

  @override
  String get default_job_unloading => 'Unloading';

  @override
  String get default_expenses_trips => 'Travel';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_section_app => 'Application';

  @override
  String get settings_section_reminders => 'Shift Reminders';

  @override
  String get settings_section_breaks => 'Break Durations (min)';

  @override
  String get settings_section_danger => 'Danger Zone';

  @override
  String get settings_field_notifications => 'Notifications';

  @override
  String get settings_field_notifications_sub => 'Allow app notifications';

  @override
  String get settings_field_theme => 'Theme';

  @override
  String get settings_field_language => 'App Language';

  @override
  String get settings_field_currency => 'Display Currency';

  @override
  String get settings_field_currency_sub =>
      'Currency used for salary and expenses';

  @override
  String get settings_field_reminder_time => 'Reminder Time (hours)';

  @override
  String get settings_field_breaks_enabled => 'Enable Breaks';

  @override
  String get settings_field_breaks_enabled_sub =>
      'Show or hide break settings in the app';

  @override
  String get settings_field_paid_break => 'Short Break (Paid)';

  @override
  String get settings_field_unpaid_break => 'Long Break (Unpaid)';

  @override
  String get settings_action_update_breaks => 'Update Times';

  @override
  String get settings_action_factory_reset => 'Full Factory Reset';

  @override
  String get settings_action_factory_reset_sub =>
      'Permanently delete all shifts, roles, and expenses';

  @override
  String get settings_dialog_update_breaks_title => 'Update Break Times';

  @override
  String get settings_dialog_factory_reset_title => 'Reset Data?';

  @override
  String get settings_dialog_factory_reset_content =>
      'Are you sure you want to delete all work data and reset the app? This action cannot be undone.';

  @override
  String get settings_dialog_final_confirm_title => 'Final Confirmation';

  @override
  String get settings_dialog_final_confirm_content_1 =>
      'Warning: All shift history, salary, and expenses will be permanently deleted.';

  @override
  String get settings_dialog_final_confirm_content_2 =>
      'Are you sure you want to delete everything?';

  @override
  String get settings_dialog_final_confirm_button => 'Permanently Delete All';

  @override
  String get settings_dialog_error_enter_desc =>
      'Please enter a description for each expense';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_light => 'Day';

  @override
  String get settings_theme_dark => 'Night';

  @override
  String get settings_language_he => 'עברית';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_current_rate => 'Current Rate';

  @override
  String get settings_wage_history_title => 'Wage History';

  @override
  String get settings_job_name_label => 'Job Name';

  @override
  String get settings_job_rate_label => 'Hourly Rate (New)';

  @override
  String get settings_job_start_date_label => 'Start Date';

  @override
  String get settings_job_error_name_empty => 'Please enter a job name';

  @override
  String get settings_job_error_exists => 'Job with this name already exists';

  @override
  String get settings_job_error_negative_rate => 'Wage cannot be negative';

  @override
  String get settings_job_add_confirm_title => 'Add Job';

  @override
  String get settings_job_edit_confirm_title => 'Update Job';

  @override
  String get settings_job_save_confirm_content =>
      'Save job \"[[name]]\" with rate [[rate]] starting [[date]]?';

  @override
  String get settings_job_delete_confirm_title => 'Delete Job';

  @override
  String get settings_job_delete_confirm_content =>
      'Are you sure you want to delete job \"[[name]]\"?';

  @override
  String get settings_job_deleted_msg => 'Job \"[[name]]\" deleted';

  @override
  String get settings_dialog_update_breaks_content =>
      'Update default break times to [[paid]] min paid and [[unpaid]] min unpaid?';

  @override
  String get settings_breaks_updated_msg => 'Break durations updated';

  @override
  String get settings_jobs_empty => 'No job types found.';

  @override
  String get settings_reset_success_msg => 'App reset successfully';

  @override
  String get home_empty_state_title => 'No shifts registered yet';

  @override
  String get home_empty_state_subtitle => 'Click \"New Shift\" to get started';

  @override
  String get home_total_card_title => 'Total Accumulated (Net less expenses)';

  @override
  String get home_total_card_hours => 'Hours';

  @override
  String get home_total_card_base => 'Base';

  @override
  String get home_total_card_tips => 'Tips';

  @override
  String get home_total_card_expenses => 'Expenses';

  @override
  String get home_active_timer_break => 'Shift on break...';

  @override
  String get home_active_timer_active => 'Active Shift:';

  @override
  String get home_active_timer_time => 'Time:';

  @override
  String get home_shift_list_net_total => 'Net Total';

  @override
  String get home_shift_list_no_shifts => 'No shifts on this day';

  @override
  String get home_shift_list_select_day => 'Select a day to show shifts';

  @override
  String get home_shift_list_shifts_on => 'Shifts on ';

  @override
  String get home_action_new_shift => 'New Shift';

  @override
  String get home_action_calendar => 'Calendar';

  @override
  String get expenses_title => 'Expense Management';

  @override
  String get expenses_auto_section_title => 'Recurring Shift Expenses';

  @override
  String get expenses_auto_section_subtitle =>
      'Add recurring expenses to each new shift';

  @override
  String get expenses_auto_section_enable => 'Auto Expenses';

  @override
  String get expenses_history_section_title => 'Monthly Expense Breakdown';

  @override
  String get expenses_action_add_auto => 'Add Recurring Expense';

  @override
  String get expenses_action_update_settings => 'Update Settings';

  @override
  String get expenses_action_new_expense => 'New Expense';

  @override
  String get expenses_dialog_add_title => 'Add Expense';

  @override
  String get expenses_dialog_edit_title => 'Edit Expense';

  @override
  String get expenses_dialog_delete_title => 'Delete Expense';

  @override
  String get expenses_no_history => 'No expenses recorded';

  @override
  String get expenses_save_expense_confirm_content =>
      'Save expense \"[[desc]]\" for [[amount]]?';

  @override
  String get expenses_delete_expense_confirm_content =>
      'Delete \"[[desc]]\" for [[amount]]?';

  @override
  String get expenses_total_label => 'Total';

  @override
  String get expenses_auto_updated_msg => 'Auto expense settings updated';

  @override
  String get expenses_deleted_msg => 'Expense deleted';

  @override
  String get add_shift_title => 'New Shift';

  @override
  String get add_shift_edit_title => 'Edit Shift';

  @override
  String get add_shift_timer_tab => 'Timer';

  @override
  String get add_shift_manual_tab => 'Manual';

  @override
  String get add_shift_paste_tab => 'Paste';

  @override
  String get add_shift_timer_accumulated_live => 'Accumulated Live';

  @override
  String get add_shift_timer_countdown => 'Countdown: ';

  @override
  String get add_shift_timer_break_paid => 'On paid break...';

  @override
  String get add_shift_timer_break_unpaid => 'On unpaid break (timer stopped)';

  @override
  String get add_shift_timer_total_break_unpaid => 'Total Unpaid Break:';

  @override
  String get add_shift_timer_resume_work => 'Back to work';

  @override
  String get add_shift_timer_stop_shift => 'Stop Shift';

  @override
  String get add_shift_timer_start_shift => 'Start Shift';

  @override
  String get add_shift_timer_continue_work => 'Continue Work';

  @override
  String get add_shift_timer_stopped_msg =>
      'The timer stopped. Would you like to save the shift or continue working?';

  @override
  String get add_shift_timer_reset_title => 'Reset Timer';

  @override
  String get add_shift_timer_reset_desc =>
      'Are you sure you want to reset the timer? All current data will be lost.';

  @override
  String get add_shift_timer_resume_shift => 'Resume Shift';

  @override
  String get add_shift_manual_time_section => 'Time';

  @override
  String get add_shift_manual_date_label => 'Date';

  @override
  String get add_shift_manual_start_time_label => 'Start Time';

  @override
  String get add_shift_manual_end_time_label => 'End Time';

  @override
  String get add_shift_manual_break_type_section => 'Break Type';

  @override
  String get add_shift_manual_no_break => 'None';

  @override
  String get add_shift_manual_paid_break => 'Paid';

  @override
  String get add_shift_manual_unpaid_break => 'Unpaid';

  @override
  String get add_shift_manual_work_tips_section => 'Work & Tips';

  @override
  String get add_shift_manual_job_type_label => 'Job Type';

  @override
  String get add_shift_paste_title => 'Paste Shift Text';

  @override
  String get add_shift_paste_default_job_label => 'Default Job Type';

  @override
  String get add_shift_paste_format_info =>
      'Format: DD.MM.YYYY - HH:mm - HH:mm [break] [+ tips]\nBreaks: none / 20 minutes / 45 minutes';

  @override
  String get add_shift_paste_hint =>
      'Paste shifts here...\nExample:\n24.6.2026 - 17:30 - 23:00 45 minutes + 50';

  @override
  String get add_shift_paste_parse_button => 'Parse & Save All';

  @override
  String get add_shift_paste_parse_dialog_title => 'Parse Shifts';

  @override
  String get add_shift_paste_parse_dialog_desc =>
      'Parse and save shifts from the pasted text?';

  @override
  String get add_shift_paste_error => 'Please check the format and try again';

  @override
  String get add_shift_tips_title => 'Tips';

  @override
  String get add_shift_tips_total => 'Total';

  @override
  String get add_shift_tips_hint => 'Tip amount';

  @override
  String get add_shift_tips_add_button => 'Add Tip';

  @override
  String get add_shift_expenses_title => 'Shift Expenses';

  @override
  String get add_shift_expenses_total => 'Total';

  @override
  String get add_shift_expenses_add_button => 'Add Expense';

  @override
  String get add_shift_shift_ended_dialog_title => 'Save Shift';

  @override
  String get add_shift_shift_ended_dialog_desc =>
      'Are you sure you want to save the shift details?';

  @override
  String get add_shift_shift_ended_edit_dialog_desc =>
      'Are you sure you want to save the shift details?';

  @override
  String get add_shift_shift_edit_dialog_title => 'Update Shift';

  @override
  String get add_shift_shift_saved => 'Shift saved successfully';

  @override
  String get add_shift_pick_a_job => 'Please select a job type first';

  @override
  String get add_shift_delete_title => 'Delete Shift';

  @override
  String get add_shift_delete_desc =>
      'Are you sure you want to delete the shift from';

  @override
  String get add_shift_delete_msg => 'Shift deleted successfully';

  @override
  String get notification_reminder_title => 'Shift Reminder';

  @override
  String get notification_reminder_body =>
      'Your shift ([[name]]) starts in [[time]]!';

  @override
  String get notification_channel_reminders_name => 'Shift Reminders';

  @override
  String get notification_channel_reminders_desc =>
      'Reminders before shift starts';

  @override
  String get notification_timer_channel_name => 'Active Shift';

  @override
  String get notification_timer_channel_desc => 'Shows current shift timer';

  @override
  String get notification_timer_title_active => 'Active Shift';

  @override
  String get notification_timer_title_paid_break => 'Paid Break';

  @override
  String get notification_timer_title_unpaid_break => 'Unpaid Break';

  @override
  String get notification_timer_body_running => 'Timer running...';

  @override
  String get notification_timer_body_countdown => 'Countdown: [[time]]';

  @override
  String get filter_title => 'Shift Filters';

  @override
  String get filter_clear_all => 'Reset Filter';

  @override
  String get filter_apply => 'Apply Filters';

  @override
  String get filter_wage_range => 'Total Wage Range';

  @override
  String get filter_tips_range => 'Tips Range';

  @override
  String get filter_expenses_range => 'Expenses Range';

  @override
  String get filter_duration_range => 'Duration Range (Hours)';

  @override
  String get filter_date_range => 'Date Range';

  @override
  String get filter_job_type => 'Job Type';

  @override
  String get filter_select_all => 'Select All';

  @override
  String get filter_error_no_job_selected =>
      'Please select at least one job type';

  @override
  String get filter_min => 'Min';

  @override
  String get filter_max => 'Max';

  @override
  String get filter_active_filters => 'Active Filters:';

  @override
  String get filter_no_results => 'No shifts match these filters';

  @override
  String get filter_chip_wage => 'Wage: [[min]] - [[max]]';

  @override
  String get filter_chip_tips => 'Tips: [[min]] - [[max]]';

  @override
  String get filter_chip_expenses => 'Expenses: [[min]] - [[max]]';

  @override
  String get filter_chip_duration => 'Duration: [[min]] - [[max]] h';

  @override
  String get filter_chip_date => 'Date: [[start]] - [[end]]';

  @override
  String get filter_chip_job => 'Job: [[name]]';

  @override
  String get filter_empty_state_title => 'No matching shifts';

  @override
  String get filter_empty_state_subtitle =>
      'Try adjusting your filters to see more results';

  @override
  String get auth_login_title => 'Welcome Back';

  @override
  String get auth_register_title => 'Create New Account';

  @override
  String get auth_full_name_label => 'Full Name';

  @override
  String get auth_email_label => 'Email';

  @override
  String get auth_password_label => 'Password';

  @override
  String get auth_error_name_empty => 'Please enter name';

  @override
  String get auth_error_email_invalid => 'Invalid email';

  @override
  String get auth_error_password_length =>
      'Password must be at least 6 characters';

  @override
  String get auth_login_button => 'Login';

  @override
  String get auth_register_button => 'Register';

  @override
  String get auth_no_account_link => 'No account? Register now';

  @override
  String get auth_has_account_link => 'Already have an account? Login';

  @override
  String get auth_error_generic => 'An error occurred. Please try again.';

  @override
  String get settings_section_account => 'Account';

  @override
  String get settings_logout_title => 'Logout from system';

  @override
  String get settings_logout_subtitle => 'Logout from current account';

  @override
  String get settings_logout_dialog_title => 'Logout';

  @override
  String get settings_logout_confirm_content =>
      'Are you sure you want to logout?';

  @override
  String get settings_logout_confirm_button => 'Logout';

  @override
  String get auth_login_success => 'Login successful';

  @override
  String get auth_register_success => 'Account created successfully';

  @override
  String get home_welcome_back => 'Hello, [[name]]';

  @override
  String get settings_user_details_title => 'User Details';

  @override
  String get settings_user_name => 'Name';

  @override
  String get settings_user_email => 'Email';

  @override
  String get settings_user_password => 'Password';

  @override
  String get settings_user_edit_title => 'Edit Profile';

  @override
  String get settings_user_update_button => 'Update Details';

  @override
  String get settings_user_update_success => 'Profile updated successfully';

  @override
  String get settings_logout_success => 'Logged out successfully';

  @override
  String get settings_byos_title => 'BYOS Sync';

  @override
  String get settings_byos_connected => 'Connected to Google Drive';

  @override
  String get settings_byos_last_backup => 'Last backup: [[time]]';

  @override
  String get settings_byos_disconnect => 'Disconnect';

  @override
  String get settings_byos_upgrade_title => 'Create Shiftly Account';

  @override
  String get settings_byos_upgrade_subtitle =>
      'Transfer BYOS data to our cloud for faster sync';

  @override
  String get settings_byos_sync_backup_section => 'Sync & Backup';

  @override
  String get settings_byos_login_shiftly => 'Login to Shiftly Account';

  @override
  String get settings_byos_login_shiftly_sub => 'Full sync in our cloud';

  @override
  String get settings_byos_method_title => 'BYOS Method (Google Drive)';

  @override
  String get settings_byos_method_sub => 'Backup to your private cloud';

  @override
  String get settings_byos_restore_dialog_title => 'BYOS Sync';

  @override
  String get settings_byos_restore_dialog_content =>
      'Would you like to restore existing data from your Google Drive?';

  @override
  String get settings_byos_restore_confirm => 'Restore';

  @override
  String get settings_byos_restore_cancel => 'Not now';

  @override
  String get settings_byos_login_hint =>
      'Login to backup data to cloud and use more devices';

  @override
  String get auth_sync_dialog_title => 'Data Sync';

  @override
  String get auth_sync_dialog_content =>
      'Data was found both locally and in the cloud. Which one would you like to use?\n\n• Keeping local data will upload it to the cloud.\n• Using cloud data will overwrite local data.';

  @override
  String get auth_sync_dialog_cloud => 'Cloud Data';

  @override
  String get auth_sync_dialog_local => 'Local Data';
}
