// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get common_app_name => 'Shiftly';

  @override
  String get common_continue => 'המשך';

  @override
  String get common_back => 'חזור';

  @override
  String get common_start => 'בוא נתחיל!';

  @override
  String get common_cancel => 'ביטול';

  @override
  String get common_save => 'שמור';

  @override
  String get common_delete => 'מחק';

  @override
  String get common_confirm => 'אישור';

  @override
  String get common_error => 'שגיאה';

  @override
  String get common_success => 'הצלחה';

  @override
  String get common_add => 'הוסף';

  @override
  String get common_edit => 'עריכה';

  @override
  String get common_calendar_title => 'לוח משמרות';

  @override
  String get common_tagline => 'מעקב שעות עבודה חכם';

  @override
  String get common_hours_suffix => 'שעות';

  @override
  String get common_min_suffix => 'דק\'';

  @override
  String get common_net => 'נטו';

  @override
  String get common_shifts_count => 'משמרות';

  @override
  String get common_delete_shit_short => 'מחיקת משמרת';

  @override
  String get common_delete_shit_expanded =>
      'האם אתה בטוח שברצונך למחוק את המשמרת מיום ';

  @override
  String get common_delete_shift_after => 'המשמרת נמחקה בהצלחה';

  @override
  String get common_save_and_finish => 'שמור וסיים';

  @override
  String get common_reset => 'אפס';

  @override
  String get common_reset_and_cancel => 'ביטול ואיפוס';

  @override
  String get common_undo => 'ביטול';

  @override
  String get onboarding_welcome_title => 'ברוכים הבאים ל-Shiftly';

  @override
  String get onboarding_welcome_subtitle =>
      'האפליקציה שתעזור לך לעקוב אחרי המשמרות, השכר והטיפים שלך בקלות ובדיוק.';

  @override
  String get onboarding_welcome_description =>
      'בוא נגדיר כמה דברים בסיסיים כדי להתחיל.';

  @override
  String get onboarding_language_title => 'שפת אפליקציה';

  @override
  String get onboarding_language_subtitle => 'בחר את השפה המועדפת עליך.';

  @override
  String get onboarding_currency_title => 'בחירת מטבע';

  @override
  String get onboarding_currency_subtitle =>
      'באיזה מטבע תרצה להשתמש להצגת השכר וההוצאות?';

  @override
  String get onboarding_breaks_title => 'הגדרות הפסקה';

  @override
  String get onboarding_breaks_subtitle => 'כמה זמן נמשכת הפסקה בדרך כלל?';

  @override
  String get onboarding_breaks_enable => 'אפשר הפסקות';

  @override
  String get onboarding_breaks_paid_label => 'הפסקה בתשלום (דקות)';

  @override
  String get onboarding_breaks_unpaid_label => 'הפסקה ללא תשלום (דקות)';

  @override
  String get onboarding_reminders_title => 'תזכורות למשמרת';

  @override
  String get onboarding_reminders_subtitle =>
      'האם תרצה לקבל תזכורת לפני שהמשמרת מתחילה?';

  @override
  String get onboarding_reminders_enable => 'הפעל תזכורות';

  @override
  String get onboarding_reminders_time_label => 'כמה זמן לפני? (שעות)';

  @override
  String get onboarding_reminders_hours => 'שעות';

  @override
  String get onboarding_auto_expenses_title => 'הוצאות קבועות';

  @override
  String get onboarding_auto_expenses_subtitle =>
      'האם יש לך הוצאות קבועות בכל משמרת? (למשל נסיעות)';

  @override
  String get onboarding_auto_expenses_enable => 'הפעל הוצאות אוטומטיות';

  @override
  String get onboarding_auto_expenses_add_button => 'הוסף הוצאה';

  @override
  String get onboarding_auto_expenses_desc_label => 'תיאור';

  @override
  String get onboarding_auto_expenses_amount_label => '₪';

  @override
  String get onboarding_auto_expenses_invalid_amount =>
      'סכום ההוצאה חייב להיות גדול מ-0';

  @override
  String get onboarding_job_types_title => 'סוגי משמרות ושכר';

  @override
  String get onboarding_job_types_subtitle =>
      'הגדר את התפקידים השונים שלך ואת השכר לשעה.';

  @override
  String get onboarding_job_types_add_button => 'הוספת סוג עבודה';

  @override
  String get onboarding_job_types_edit_button => 'עריכת סוג עבודה';

  @override
  String get onboarding_job_types_delete_title => 'מחיקת תפקיד';

  @override
  String get onboarding_job_types_delete_desc => 'האם למחוק את התפקיד ';

  @override
  String get onboarding_job_types_rate_suffix => 'לשעה';

  @override
  String get onboarding_job_types_same => 'תפקיד בשם זה כבר קיים';

  @override
  String get default_job_buffet => 'מזנון';

  @override
  String get default_job_steward => 'סדרן';

  @override
  String get default_job_unloading => 'פריקה';

  @override
  String get default_expenses_trips => 'נסיעות';

  @override
  String get settings_title => 'הגדרות';

  @override
  String get settings_section_app => 'אפליקציה';

  @override
  String get settings_section_reminders => 'תזכורות משמרת';

  @override
  String get settings_section_breaks => 'זמני הפסקות (דקות)';

  @override
  String get settings_section_danger => 'אזור מסוכן';

  @override
  String get settings_field_notifications => 'התראות';

  @override
  String get settings_field_notifications_sub => 'אפשר שליחת התראות מהאפליקציה';

  @override
  String get settings_field_theme => 'ערכת נושא';

  @override
  String get settings_field_language => 'שפת אפליקציה';

  @override
  String get settings_field_currency => 'מטבע תצוגה';

  @override
  String get settings_field_currency_sub => 'המטבע שיוצג עבור שכר והוצאות';

  @override
  String get settings_field_reminder_time => 'זמן תזכורת (שעות)';

  @override
  String get settings_field_breaks_enabled => 'אפשר הפסקות';

  @override
  String get settings_field_breaks_enabled_sub =>
      'הצג או הסתר הגדרות הפסקה באפליקציה';

  @override
  String get settings_field_paid_break => 'הפסקה קצרה (בתשלום)';

  @override
  String get settings_field_unpaid_break => 'הפסקה ארוכה (ללא תשלום)';

  @override
  String get settings_action_update_breaks => 'עדכן זמנים';

  @override
  String get settings_action_factory_reset => 'איפוס נתונים מלא';

  @override
  String get settings_action_factory_reset_sub =>
      'מחיקת כל המשמרות, התפקידים וההוצאות לצמיתות';

  @override
  String get settings_dialog_update_breaks_title => 'עדכון זמני הפסקה';

  @override
  String get settings_dialog_factory_reset_title => 'איפוס נתונים?';

  @override
  String get settings_dialog_factory_reset_content =>
      'האם אתה בטוח שברצונך למחוק את כל נתוני העבודה ולאפס את האפליקציה? פעולה זו אינה ניתנת לביטול.';

  @override
  String get settings_dialog_final_confirm_title => 'אישור סופי ומוחלט';

  @override
  String get settings_dialog_final_confirm_content_1 =>
      'שימו לב: כל היסטוריית המשמרות, השכר וההוצאות תימחק לעד.';

  @override
  String get settings_dialog_final_confirm_content_2 =>
      'האם אתה בטוח שברצונך למחוק הכל?';

  @override
  String get settings_dialog_final_confirm_button => 'מחק הכל לצמיתות';

  @override
  String get settings_dialog_error_enter_desc =>
      'נא להזין תיאור לכל הוצאה קבועה';

  @override
  String get settings_theme_system => 'מערכת';

  @override
  String get settings_theme_light => 'יום';

  @override
  String get settings_theme_dark => 'לילה';

  @override
  String get settings_language_he => 'עברית';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_current_rate => 'תעריף נוכחי';

  @override
  String get settings_wage_history_title => 'היסטוריית שכר';

  @override
  String get settings_job_name_label => 'שם התפקיד';

  @override
  String get settings_job_rate_label => 'תעריף שעתי (חדש)';

  @override
  String get settings_job_start_date_label => 'תאריך תחילה';

  @override
  String get settings_job_error_name_empty => 'נא להזין שם לתפקיד';

  @override
  String get settings_job_error_exists => 'תפקיד בשם זה כבר קיים';

  @override
  String get settings_job_error_negative_rate => 'השכר לא יכול להיות שלילי';

  @override
  String get settings_job_add_confirm_title => 'הוספת תפקיד';

  @override
  String get settings_job_edit_confirm_title => 'עדכון תפקיד';

  @override
  String get settings_job_save_confirm_content =>
      'האם לשמור את התפקיד \"[[name]]\" עם שכר של [[rate]] החל מיום [[date]]?';

  @override
  String get settings_job_delete_confirm_title => 'מחיקת תפקיד';

  @override
  String get settings_job_delete_confirm_content =>
      'האם אתה בטוח שברצונך למחוק את התפקיד \"[[name]]\"?';

  @override
  String get settings_job_deleted_msg => 'תפקיד \"[[name]]\" נמחק';

  @override
  String get settings_dialog_update_breaks_content =>
      'האם לעדכן את זמני ברירת המחדל ל-[[paid]] דק\' בתשלום ו-[[unpaid]] דק\' ללא תשלום?';

  @override
  String get settings_breaks_updated_msg => 'זמני ההפסקות עודכנו';

  @override
  String get settings_jobs_empty => 'לא נמצאו תפקידים.';

  @override
  String get settings_reset_success_msg => 'האפליקציה אותחלה בהצלחה';

  @override
  String get home_empty_state_title => 'עדיין לא נרשמו משמרות';

  @override
  String get home_empty_state_subtitle => 'לחץ על \"משמרת חדשה\" כדי להתחיל';

  @override
  String get home_total_card_title => 'סה\"כ הצטבר (נטו פחות הוצאות)';

  @override
  String get home_total_card_hours => 'שעות';

  @override
  String get home_total_card_base => 'בסיס';

  @override
  String get home_total_card_tips => 'טיפים';

  @override
  String get home_total_card_expenses => 'הוצאות';

  @override
  String get home_active_timer_break => 'משמרת בהפסקה...';

  @override
  String get home_active_timer_active => 'משמרת פעילה:';

  @override
  String get home_active_timer_time => 'זמן:';

  @override
  String get home_shift_list_net_total => 'סה\"כ נטו';

  @override
  String get home_shift_list_no_shifts => 'אין משמרות ביום זה';

  @override
  String get home_shift_list_select_day => 'בחר יום להצגת משמרות';

  @override
  String get home_shift_list_shifts_on => 'משמרות ב-';

  @override
  String get home_action_new_shift => 'משמרת חדשה';

  @override
  String get home_action_calendar => 'לוח משמרות';

  @override
  String get expenses_title => 'ניהול הוצאות';

  @override
  String get expenses_auto_section_title => 'הוצאות קבועות למשמרת';

  @override
  String get expenses_auto_section_subtitle =>
      'הוסף הוצאות קבועות לכל משמרת חדשה';

  @override
  String get expenses_auto_section_enable => 'הוצאות אוטומטיות';

  @override
  String get expenses_history_section_title => 'פירוט הוצאות חודשי';

  @override
  String get expenses_action_add_auto => 'הוסף הוצאה קבועה';

  @override
  String get expenses_action_update_settings => 'עדכן הגדרות';

  @override
  String get expenses_action_new_expense => 'הוצאה חדשה';

  @override
  String get expenses_dialog_add_title => 'הוספת הוצאה';

  @override
  String get expenses_dialog_edit_title => 'עריכת הוצאה';

  @override
  String get expenses_dialog_delete_title => 'מחיקת הוצאה';

  @override
  String get expenses_no_history => 'אין הוצאות רשומות';

  @override
  String get expenses_save_expense_confirm_content =>
      'האם לשמור את ההוצאה \"[[desc]]\" בסך [[amount]]?';

  @override
  String get expenses_delete_expense_confirm_content =>
      'האם למחוק את ההוצאה \"[[desc]]\" בסך [[amount]]?';

  @override
  String get expenses_total_label => 'סה\"כ';

  @override
  String get expenses_auto_updated_msg => 'הגדרות הוצאות אוטומטיות עודכנו';

  @override
  String get expenses_deleted_msg => 'הוצאה נמחקה';

  @override
  String get add_shift_title => 'רישום משמרת';

  @override
  String get add_shift_edit_title => 'עריכת משמרת';

  @override
  String get add_shift_timer_tab => 'טיימר';

  @override
  String get add_shift_manual_tab => 'ידני';

  @override
  String get add_shift_paste_tab => 'הדבקה';

  @override
  String get add_shift_timer_accumulated_live => 'נצבר בשידור חי';

  @override
  String get add_shift_timer_countdown => 'ספירה לאחור: ';

  @override
  String get add_shift_timer_break_paid => 'בהפסקה בתשלום...';

  @override
  String get add_shift_timer_break_unpaid => 'בהפסקה ללא תשלום (השעון עצר)';

  @override
  String get add_shift_timer_total_break_unpaid => 'סה\"כ הפסקה (לא בתשלום):';

  @override
  String get add_shift_timer_resume_work => 'חזור לעבודה';

  @override
  String get add_shift_timer_stop_shift => 'סיים משמרת';

  @override
  String get add_shift_timer_start_shift => 'התחל משמרת';

  @override
  String get add_shift_timer_continue_work => 'המשך עבודה';

  @override
  String get add_shift_timer_stopped_msg =>
      'הטיימר נעצר. האם ברצונך לשמור את המשמרת או להמשיך בעבודה?';

  @override
  String get add_shift_timer_reset_title => 'איפוס טיימר';

  @override
  String get add_shift_timer_reset_desc =>
      'האם אתה בטוח שברצונך לאפס את הטיימר? כל המידע הנוכחי יימחק.';

  @override
  String get add_shift_timer_resume_shift => 'המשך משמרת';

  @override
  String get add_shift_manual_time_section => 'זמן';

  @override
  String get add_shift_manual_date_label => 'תאריך';

  @override
  String get add_shift_manual_start_time_label => 'שעת התחלה';

  @override
  String get add_shift_manual_end_time_label => 'שעת סיום';

  @override
  String get add_shift_manual_break_type_section => 'סוג הפסקה';

  @override
  String get add_shift_manual_no_break => 'ללא';

  @override
  String get add_shift_manual_paid_break => 'בתשלום';

  @override
  String get add_shift_manual_unpaid_break => 'ללא תשלום';

  @override
  String get add_shift_manual_work_tips_section => 'עבודה וטיפים';

  @override
  String get add_shift_manual_job_type_label => 'סוג עבודה';

  @override
  String get add_shift_paste_title => 'הדבקה חופשית';

  @override
  String get add_shift_paste_default_job_label => 'סוג עבודה ברירת מחדל';

  @override
  String get add_shift_paste_format_info =>
      'פורמט: DD.MM.YYYY - HH:mm - HH:mm [הפסקה] [+ tips]\nהפסקות: ללא / 20 דקות / 45 דקות';

  @override
  String get add_shift_paste_hint =>
      'הדבק משמרות כאן...\nלדוגמה:\n24.6.2026 - 17:30 - 23:00 45 דקות + 50';

  @override
  String get add_shift_paste_parse_button => 'פענח ושמור הכל';

  @override
  String get add_shift_paste_parse_dialog_title => 'פענוח משמרות';

  @override
  String get add_shift_paste_parse_dialog_desc =>
      'האם לפענח ולשמור משמרות מהטקסט שהודבק?';

  @override
  String get add_shift_paste_error => 'בדוק שוב שהפורמט שהזנת תקין';

  @override
  String get add_shift_tips_title => 'טיפים';

  @override
  String get add_shift_tips_total => 'סה\"כ';

  @override
  String get add_shift_tips_hint => 'סכום טיפ';

  @override
  String get add_shift_tips_add_button => 'הוסף טיפ';

  @override
  String get add_shift_expenses_title => 'הוצאות למשמרת';

  @override
  String get add_shift_expenses_total => 'סה\"כ';

  @override
  String get add_shift_expenses_add_button => 'הוסף הוצאה';

  @override
  String get add_shift_shift_ended_dialog_title => 'שמירת משמרת';

  @override
  String get add_shift_shift_ended_dialog_desc =>
      'האם אתה בטוח שברצונך לשמור את פרטי המשמרת?';

  @override
  String get add_shift_shift_ended_edit_dialog_desc =>
      'האם אתה בטוח שברצונך לשמור את פרטי המשמרת?';

  @override
  String get add_shift_shift_edit_dialog_title => 'עדכון משמרת';

  @override
  String get add_shift_shift_saved => 'המשמרת נשמרה בהצלחה';

  @override
  String get add_shift_pick_a_job => 'בחר סוג עבודה קודם';

  @override
  String get add_shift_delete_title => 'מחיקת משמרת';

  @override
  String get add_shift_delete_desc =>
      'האם אתה בטוח שברצונך למחוק את המשמרת מיום ';

  @override
  String get add_shift_delete_msg => 'המשמרת נמחקה בהצלחה: ';

  @override
  String get notification_reminder_title => 'תזכורת למשמרת';

  @override
  String get notification_reminder_body =>
      'המשמרת שלך ([[name]]) מתחילה בעוד [[time]]!';

  @override
  String get notification_channel_reminders_name => 'תזכורות משמרת';

  @override
  String get notification_channel_reminders_desc => 'תזכורת לפני תחילת משמרת';

  @override
  String get notification_timer_channel_name => 'משמרת פעילה';

  @override
  String get notification_timer_channel_desc => 'מציג את זמן המשמרת הנוכחית';

  @override
  String get notification_timer_title_active => 'משמרת פעילה';

  @override
  String get notification_timer_title_paid_break => 'הפסקה בתשלום';

  @override
  String get notification_timer_title_unpaid_break => 'הפסקה ללא תשלום';

  @override
  String get notification_timer_body_running => 'הטיימר רץ...';

  @override
  String get notification_timer_body_countdown => 'ספירה לאחור: [[time]]';
}
