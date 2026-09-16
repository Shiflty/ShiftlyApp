import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
  ];

  /// No description provided for @common_app_name.
  ///
  /// In he, this message translates to:
  /// **'Shiftly'**
  String get common_app_name;

  /// No description provided for @common_continue.
  ///
  /// In he, this message translates to:
  /// **'המשך'**
  String get common_continue;

  /// No description provided for @common_back.
  ///
  /// In he, this message translates to:
  /// **'חזור'**
  String get common_back;

  /// No description provided for @common_start.
  ///
  /// In he, this message translates to:
  /// **'בוא נתחיל!'**
  String get common_start;

  /// No description provided for @common_cancel.
  ///
  /// In he, this message translates to:
  /// **'ביטול'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In he, this message translates to:
  /// **'שמור'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In he, this message translates to:
  /// **'מחק'**
  String get common_delete;

  /// No description provided for @common_confirm.
  ///
  /// In he, this message translates to:
  /// **'אישור'**
  String get common_confirm;

  /// No description provided for @common_error.
  ///
  /// In he, this message translates to:
  /// **'שגיאה'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In he, this message translates to:
  /// **'הצלחה'**
  String get common_success;

  /// No description provided for @common_add.
  ///
  /// In he, this message translates to:
  /// **'הוסף'**
  String get common_add;

  /// No description provided for @common_edit.
  ///
  /// In he, this message translates to:
  /// **'עריכה'**
  String get common_edit;

  /// No description provided for @common_calendar_title.
  ///
  /// In he, this message translates to:
  /// **'לוח משמרות'**
  String get common_calendar_title;

  /// No description provided for @common_tagline.
  ///
  /// In he, this message translates to:
  /// **'מעקב שעות עבודה חכם'**
  String get common_tagline;

  /// No description provided for @common_hours_suffix.
  ///
  /// In he, this message translates to:
  /// **'שעות'**
  String get common_hours_suffix;

  /// No description provided for @common_min_suffix.
  ///
  /// In he, this message translates to:
  /// **'דק\''**
  String get common_min_suffix;

  /// No description provided for @common_net.
  ///
  /// In he, this message translates to:
  /// **'נטו'**
  String get common_net;

  /// No description provided for @common_shifts_count.
  ///
  /// In he, this message translates to:
  /// **'משמרות'**
  String get common_shifts_count;

  /// No description provided for @common_delete_shit_short.
  ///
  /// In he, this message translates to:
  /// **'מחיקת משמרת'**
  String get common_delete_shit_short;

  /// No description provided for @common_delete_shit_expanded.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את המשמרת מיום '**
  String get common_delete_shit_expanded;

  /// No description provided for @common_delete_shift_after.
  ///
  /// In he, this message translates to:
  /// **'המשמרת נמחקה בהצלחה'**
  String get common_delete_shift_after;

  /// No description provided for @common_save_and_finish.
  ///
  /// In he, this message translates to:
  /// **'שמור וסיים'**
  String get common_save_and_finish;

  /// No description provided for @common_reset.
  ///
  /// In he, this message translates to:
  /// **'אפס'**
  String get common_reset;

  /// No description provided for @common_reset_and_cancel.
  ///
  /// In he, this message translates to:
  /// **'ביטול ואיפוס'**
  String get common_reset_and_cancel;

  /// No description provided for @common_undo.
  ///
  /// In he, this message translates to:
  /// **'ביטול'**
  String get common_undo;

  /// No description provided for @onboarding_welcome_title.
  ///
  /// In he, this message translates to:
  /// **'ברוכים הבאים ל-Shiftly'**
  String get onboarding_welcome_title;

  /// No description provided for @onboarding_welcome_subtitle.
  ///
  /// In he, this message translates to:
  /// **'האפליקציה שתעזור לך לעקוב אחרי המשמרות, השכר והטיפים שלך בקלות ובדיוק.'**
  String get onboarding_welcome_subtitle;

  /// No description provided for @onboarding_welcome_description.
  ///
  /// In he, this message translates to:
  /// **'בוא נגדיר כמה דברים בסיסיים כדי להתחיל.'**
  String get onboarding_welcome_description;

  /// No description provided for @onboarding_language_title.
  ///
  /// In he, this message translates to:
  /// **'שפת אפליקציה'**
  String get onboarding_language_title;

  /// No description provided for @onboarding_language_subtitle.
  ///
  /// In he, this message translates to:
  /// **'בחר את השפה המועדפת עליך.'**
  String get onboarding_language_subtitle;

  /// No description provided for @onboarding_currency_title.
  ///
  /// In he, this message translates to:
  /// **'בחירת מטבע'**
  String get onboarding_currency_title;

  /// No description provided for @onboarding_currency_subtitle.
  ///
  /// In he, this message translates to:
  /// **'באיזה מטבע תרצה להשתמש להצגת השכר וההוצאות?'**
  String get onboarding_currency_subtitle;

  /// No description provided for @onboarding_breaks_title.
  ///
  /// In he, this message translates to:
  /// **'הגדרות הפסקה'**
  String get onboarding_breaks_title;

  /// No description provided for @onboarding_breaks_subtitle.
  ///
  /// In he, this message translates to:
  /// **'כמה זמן נמשכת הפסקה בדרך כלל?'**
  String get onboarding_breaks_subtitle;

  /// No description provided for @onboarding_breaks_enable.
  ///
  /// In he, this message translates to:
  /// **'אפשר הפסקות'**
  String get onboarding_breaks_enable;

  /// No description provided for @onboarding_breaks_paid_label.
  ///
  /// In he, this message translates to:
  /// **'הפסקה בתשלום (דקות)'**
  String get onboarding_breaks_paid_label;

  /// No description provided for @onboarding_breaks_unpaid_label.
  ///
  /// In he, this message translates to:
  /// **'הפסקה ללא תשלום (דקות)'**
  String get onboarding_breaks_unpaid_label;

  /// No description provided for @onboarding_reminders_title.
  ///
  /// In he, this message translates to:
  /// **'תזכורות למשמרת'**
  String get onboarding_reminders_title;

  /// No description provided for @onboarding_reminders_subtitle.
  ///
  /// In he, this message translates to:
  /// **'האם תרצה לקבל תזכורת לפני שהמשמרת מתחילה?'**
  String get onboarding_reminders_subtitle;

  /// No description provided for @onboarding_reminders_enable.
  ///
  /// In he, this message translates to:
  /// **'הפעל תזכורות'**
  String get onboarding_reminders_enable;

  /// No description provided for @onboarding_reminders_time_label.
  ///
  /// In he, this message translates to:
  /// **'כמה זמן לפני? (שעות)'**
  String get onboarding_reminders_time_label;

  /// No description provided for @onboarding_reminders_hours.
  ///
  /// In he, this message translates to:
  /// **'שעות'**
  String get onboarding_reminders_hours;

  /// No description provided for @onboarding_auto_expenses_title.
  ///
  /// In he, this message translates to:
  /// **'הוצאות קבועות'**
  String get onboarding_auto_expenses_title;

  /// No description provided for @onboarding_auto_expenses_subtitle.
  ///
  /// In he, this message translates to:
  /// **'האם יש לך הוצאות קבועות בכל משמרת? (למשל נסיעות)'**
  String get onboarding_auto_expenses_subtitle;

  /// No description provided for @onboarding_auto_expenses_enable.
  ///
  /// In he, this message translates to:
  /// **'הפעל הוצאות אוטומטיות'**
  String get onboarding_auto_expenses_enable;

  /// No description provided for @onboarding_auto_expenses_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאה'**
  String get onboarding_auto_expenses_add_button;

  /// No description provided for @onboarding_auto_expenses_desc_label.
  ///
  /// In he, this message translates to:
  /// **'תיאור'**
  String get onboarding_auto_expenses_desc_label;

  /// No description provided for @onboarding_auto_expenses_amount_label.
  ///
  /// In he, this message translates to:
  /// **'₪'**
  String get onboarding_auto_expenses_amount_label;

  /// No description provided for @onboarding_auto_expenses_invalid_amount.
  ///
  /// In he, this message translates to:
  /// **'סכום ההוצאה חייב להיות גדול מ-0'**
  String get onboarding_auto_expenses_invalid_amount;

  /// No description provided for @onboarding_job_types_title.
  ///
  /// In he, this message translates to:
  /// **'סוגי משמרות ושכר'**
  String get onboarding_job_types_title;

  /// No description provided for @onboarding_job_types_subtitle.
  ///
  /// In he, this message translates to:
  /// **'הגדר את התפקידים השונים שלך ואת השכר לשעה.'**
  String get onboarding_job_types_subtitle;

  /// No description provided for @onboarding_job_types_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוספת סוג עבודה'**
  String get onboarding_job_types_add_button;

  /// No description provided for @onboarding_job_types_edit_button.
  ///
  /// In he, this message translates to:
  /// **'עריכת סוג עבודה'**
  String get onboarding_job_types_edit_button;

  /// No description provided for @onboarding_job_types_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת תפקיד'**
  String get onboarding_job_types_delete_title;

  /// No description provided for @onboarding_job_types_delete_desc.
  ///
  /// In he, this message translates to:
  /// **'האם למחוק את התפקיד '**
  String get onboarding_job_types_delete_desc;

  /// No description provided for @onboarding_job_types_rate_suffix.
  ///
  /// In he, this message translates to:
  /// **'לשעה'**
  String get onboarding_job_types_rate_suffix;

  /// No description provided for @onboarding_job_types_same.
  ///
  /// In he, this message translates to:
  /// **'תפקיד בשם זה כבר קיים'**
  String get onboarding_job_types_same;

  /// No description provided for @default_job_buffet.
  ///
  /// In he, this message translates to:
  /// **'מזנון'**
  String get default_job_buffet;

  /// No description provided for @default_job_steward.
  ///
  /// In he, this message translates to:
  /// **'סדרן'**
  String get default_job_steward;

  /// No description provided for @default_job_unloading.
  ///
  /// In he, this message translates to:
  /// **'פריקה'**
  String get default_job_unloading;

  /// No description provided for @default_expenses_trips.
  ///
  /// In he, this message translates to:
  /// **'נסיעות'**
  String get default_expenses_trips;

  /// No description provided for @settings_title.
  ///
  /// In he, this message translates to:
  /// **'הגדרות'**
  String get settings_title;

  /// No description provided for @settings_section_app.
  ///
  /// In he, this message translates to:
  /// **'אפליקציה'**
  String get settings_section_app;

  /// No description provided for @settings_section_reminders.
  ///
  /// In he, this message translates to:
  /// **'תזכורות משמרת'**
  String get settings_section_reminders;

  /// No description provided for @settings_section_breaks.
  ///
  /// In he, this message translates to:
  /// **'זמני הפסקות (דקות)'**
  String get settings_section_breaks;

  /// No description provided for @settings_section_danger.
  ///
  /// In he, this message translates to:
  /// **'אזור מסוכן'**
  String get settings_section_danger;

  /// No description provided for @settings_field_notifications.
  ///
  /// In he, this message translates to:
  /// **'התראות'**
  String get settings_field_notifications;

  /// No description provided for @settings_field_notifications_sub.
  ///
  /// In he, this message translates to:
  /// **'אפשר שליחת התראות מהאפליקציה'**
  String get settings_field_notifications_sub;

  /// No description provided for @settings_field_theme.
  ///
  /// In he, this message translates to:
  /// **'ערכת נושא'**
  String get settings_field_theme;

  /// No description provided for @settings_field_language.
  ///
  /// In he, this message translates to:
  /// **'שפת אפליקציה'**
  String get settings_field_language;

  /// No description provided for @settings_field_currency.
  ///
  /// In he, this message translates to:
  /// **'מטבע תצוגה'**
  String get settings_field_currency;

  /// No description provided for @settings_field_currency_sub.
  ///
  /// In he, this message translates to:
  /// **'המטבע שיוצג עבור שכר והוצאות'**
  String get settings_field_currency_sub;

  /// No description provided for @settings_field_reminder_time.
  ///
  /// In he, this message translates to:
  /// **'זמן תזכורת (שעות)'**
  String get settings_field_reminder_time;

  /// No description provided for @settings_field_breaks_enabled.
  ///
  /// In he, this message translates to:
  /// **'אפשר הפסקות'**
  String get settings_field_breaks_enabled;

  /// No description provided for @settings_field_breaks_enabled_sub.
  ///
  /// In he, this message translates to:
  /// **'הצג או הסתר הגדרות הפסקה באפליקציה'**
  String get settings_field_breaks_enabled_sub;

  /// No description provided for @settings_field_paid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה קצרה (בתשלום)'**
  String get settings_field_paid_break;

  /// No description provided for @settings_field_unpaid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה ארוכה (ללא תשלום)'**
  String get settings_field_unpaid_break;

  /// No description provided for @settings_action_update_breaks.
  ///
  /// In he, this message translates to:
  /// **'עדכן זמנים'**
  String get settings_action_update_breaks;

  /// No description provided for @settings_action_factory_reset.
  ///
  /// In he, this message translates to:
  /// **'איפוס נתונים מלא'**
  String get settings_action_factory_reset;

  /// No description provided for @settings_action_factory_reset_sub.
  ///
  /// In he, this message translates to:
  /// **'מחיקת כל המשמרות, התפקידים וההוצאות לצמיתות'**
  String get settings_action_factory_reset_sub;

  /// No description provided for @settings_dialog_update_breaks_title.
  ///
  /// In he, this message translates to:
  /// **'עדכון זמני הפסקה'**
  String get settings_dialog_update_breaks_title;

  /// No description provided for @settings_dialog_factory_reset_title.
  ///
  /// In he, this message translates to:
  /// **'איפוס נתונים?'**
  String get settings_dialog_factory_reset_title;

  /// No description provided for @settings_dialog_factory_reset_content.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את כל נתוני העבודה ולאפס את האפליקציה? פעולה זו אינה ניתנת לביטול.'**
  String get settings_dialog_factory_reset_content;

  /// No description provided for @settings_dialog_final_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'אישור סופי ומוחלט'**
  String get settings_dialog_final_confirm_title;

  /// No description provided for @settings_dialog_final_confirm_content_1.
  ///
  /// In he, this message translates to:
  /// **'שימו לב: כל היסטוריית המשמרות, השכר וההוצאות תימחק לעד.'**
  String get settings_dialog_final_confirm_content_1;

  /// No description provided for @settings_dialog_final_confirm_content_2.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק הכל?'**
  String get settings_dialog_final_confirm_content_2;

  /// No description provided for @settings_dialog_final_confirm_button.
  ///
  /// In he, this message translates to:
  /// **'מחק הכל לצמיתות'**
  String get settings_dialog_final_confirm_button;

  /// No description provided for @settings_dialog_error_enter_desc.
  ///
  /// In he, this message translates to:
  /// **'נא להזין תיאור לכל הוצאה קבועה'**
  String get settings_dialog_error_enter_desc;

  /// No description provided for @settings_theme_system.
  ///
  /// In he, this message translates to:
  /// **'מערכת'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In he, this message translates to:
  /// **'יום'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In he, this message translates to:
  /// **'לילה'**
  String get settings_theme_dark;

  /// No description provided for @settings_language_he.
  ///
  /// In he, this message translates to:
  /// **'עברית'**
  String get settings_language_he;

  /// No description provided for @settings_language_en.
  ///
  /// In he, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_current_rate.
  ///
  /// In he, this message translates to:
  /// **'תעריף נוכחי'**
  String get settings_current_rate;

  /// No description provided for @settings_wage_history_title.
  ///
  /// In he, this message translates to:
  /// **'היסטוריית שכר'**
  String get settings_wage_history_title;

  /// No description provided for @settings_job_name_label.
  ///
  /// In he, this message translates to:
  /// **'שם התפקיד'**
  String get settings_job_name_label;

  /// No description provided for @settings_job_rate_label.
  ///
  /// In he, this message translates to:
  /// **'תעריף שעתי (חדש)'**
  String get settings_job_rate_label;

  /// No description provided for @settings_job_start_date_label.
  ///
  /// In he, this message translates to:
  /// **'תאריך תחילה'**
  String get settings_job_start_date_label;

  /// No description provided for @settings_job_error_name_empty.
  ///
  /// In he, this message translates to:
  /// **'נא להזין שם לתפקיד'**
  String get settings_job_error_name_empty;

  /// No description provided for @settings_job_error_exists.
  ///
  /// In he, this message translates to:
  /// **'תפקיד בשם זה כבר קיים'**
  String get settings_job_error_exists;

  /// No description provided for @settings_job_error_negative_rate.
  ///
  /// In he, this message translates to:
  /// **'השכר לא יכול להיות שלילי'**
  String get settings_job_error_negative_rate;

  /// No description provided for @settings_job_add_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'הוספת תפקיד'**
  String get settings_job_add_confirm_title;

  /// No description provided for @settings_job_edit_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'עדכון תפקיד'**
  String get settings_job_edit_confirm_title;

  /// No description provided for @settings_job_save_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם לשמור את התפקיד \"[[name]]\" עם שכר של [[rate]] החל מיום [[date]]?'**
  String get settings_job_save_confirm_content;

  /// No description provided for @settings_job_delete_confirm_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת תפקיד'**
  String get settings_job_delete_confirm_title;

  /// No description provided for @settings_job_delete_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את התפקיד \"[[name]]\"?'**
  String get settings_job_delete_confirm_content;

  /// No description provided for @settings_job_deleted_msg.
  ///
  /// In he, this message translates to:
  /// **'תפקיד \"[[name]]\" נמחק'**
  String get settings_job_deleted_msg;

  /// No description provided for @settings_dialog_update_breaks_content.
  ///
  /// In he, this message translates to:
  /// **'האם לעדכן את זמני ברירת המחדל ל-[[paid]] דק\' בתשלום ו-[[unpaid]] דק\' ללא תשלום?'**
  String get settings_dialog_update_breaks_content;

  /// No description provided for @settings_breaks_updated_msg.
  ///
  /// In he, this message translates to:
  /// **'זמני ההפסקות עודכנו'**
  String get settings_breaks_updated_msg;

  /// No description provided for @settings_jobs_empty.
  ///
  /// In he, this message translates to:
  /// **'לא נמצאו תפקידים.'**
  String get settings_jobs_empty;

  /// No description provided for @settings_reset_success_msg.
  ///
  /// In he, this message translates to:
  /// **'האפליקציה אותחלה בהצלחה'**
  String get settings_reset_success_msg;

  /// No description provided for @home_empty_state_title.
  ///
  /// In he, this message translates to:
  /// **'עדיין לא נרשמו משמרות'**
  String get home_empty_state_title;

  /// No description provided for @home_empty_state_subtitle.
  ///
  /// In he, this message translates to:
  /// **'לחץ על \"משמרת חדשה\" כדי להתחיל'**
  String get home_empty_state_subtitle;

  /// No description provided for @home_total_card_title.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ הצטבר (נטו פחות הוצאות)'**
  String get home_total_card_title;

  /// No description provided for @home_total_card_hours.
  ///
  /// In he, this message translates to:
  /// **'שעות'**
  String get home_total_card_hours;

  /// No description provided for @home_total_card_base.
  ///
  /// In he, this message translates to:
  /// **'בסיס'**
  String get home_total_card_base;

  /// No description provided for @home_total_card_tips.
  ///
  /// In he, this message translates to:
  /// **'טיפים'**
  String get home_total_card_tips;

  /// No description provided for @home_total_card_expenses.
  ///
  /// In he, this message translates to:
  /// **'הוצאות'**
  String get home_total_card_expenses;

  /// No description provided for @home_active_timer_break.
  ///
  /// In he, this message translates to:
  /// **'משמרת בהפסקה...'**
  String get home_active_timer_break;

  /// No description provided for @home_active_timer_active.
  ///
  /// In he, this message translates to:
  /// **'משמרת פעילה:'**
  String get home_active_timer_active;

  /// No description provided for @home_active_timer_time.
  ///
  /// In he, this message translates to:
  /// **'זמן:'**
  String get home_active_timer_time;

  /// No description provided for @home_shift_list_net_total.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ נטו'**
  String get home_shift_list_net_total;

  /// No description provided for @home_shift_list_no_shifts.
  ///
  /// In he, this message translates to:
  /// **'אין משמרות ביום זה'**
  String get home_shift_list_no_shifts;

  /// No description provided for @home_shift_list_select_day.
  ///
  /// In he, this message translates to:
  /// **'בחר יום להצגת משמרות'**
  String get home_shift_list_select_day;

  /// No description provided for @home_shift_list_shifts_on.
  ///
  /// In he, this message translates to:
  /// **'משמרות ב-'**
  String get home_shift_list_shifts_on;

  /// No description provided for @home_action_new_shift.
  ///
  /// In he, this message translates to:
  /// **'משמרת חדשה'**
  String get home_action_new_shift;

  /// No description provided for @home_action_calendar.
  ///
  /// In he, this message translates to:
  /// **'לוח משמרות'**
  String get home_action_calendar;

  /// No description provided for @expenses_title.
  ///
  /// In he, this message translates to:
  /// **'ניהול הוצאות'**
  String get expenses_title;

  /// No description provided for @expenses_auto_section_title.
  ///
  /// In he, this message translates to:
  /// **'הוצאות קבועות למשמרת'**
  String get expenses_auto_section_title;

  /// No description provided for @expenses_auto_section_subtitle.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאות קבועות לכל משמרת חדשה'**
  String get expenses_auto_section_subtitle;

  /// No description provided for @expenses_auto_section_enable.
  ///
  /// In he, this message translates to:
  /// **'הוצאות אוטומטיות'**
  String get expenses_auto_section_enable;

  /// No description provided for @expenses_history_section_title.
  ///
  /// In he, this message translates to:
  /// **'פירוט הוצאות חודשי'**
  String get expenses_history_section_title;

  /// No description provided for @expenses_action_add_auto.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאה קבועה'**
  String get expenses_action_add_auto;

  /// No description provided for @expenses_action_update_settings.
  ///
  /// In he, this message translates to:
  /// **'עדכן הגדרות'**
  String get expenses_action_update_settings;

  /// No description provided for @expenses_action_new_expense.
  ///
  /// In he, this message translates to:
  /// **'הוצאה חדשה'**
  String get expenses_action_new_expense;

  /// No description provided for @expenses_dialog_add_title.
  ///
  /// In he, this message translates to:
  /// **'הוספת הוצאה'**
  String get expenses_dialog_add_title;

  /// No description provided for @expenses_dialog_edit_title.
  ///
  /// In he, this message translates to:
  /// **'עריכת הוצאה'**
  String get expenses_dialog_edit_title;

  /// No description provided for @expenses_dialog_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת הוצאה'**
  String get expenses_dialog_delete_title;

  /// No description provided for @expenses_no_history.
  ///
  /// In he, this message translates to:
  /// **'אין הוצאות רשומות'**
  String get expenses_no_history;

  /// No description provided for @expenses_save_expense_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם לשמור את ההוצאה \"[[desc]]\" בסך [[amount]]?'**
  String get expenses_save_expense_confirm_content;

  /// No description provided for @expenses_delete_expense_confirm_content.
  ///
  /// In he, this message translates to:
  /// **'האם למחוק את ההוצאה \"[[desc]]\" בסך [[amount]]?'**
  String get expenses_delete_expense_confirm_content;

  /// No description provided for @expenses_total_label.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ'**
  String get expenses_total_label;

  /// No description provided for @expenses_auto_updated_msg.
  ///
  /// In he, this message translates to:
  /// **'הגדרות הוצאות אוטומטיות עודכנו'**
  String get expenses_auto_updated_msg;

  /// No description provided for @expenses_deleted_msg.
  ///
  /// In he, this message translates to:
  /// **'הוצאה נמחקה'**
  String get expenses_deleted_msg;

  /// No description provided for @add_shift_title.
  ///
  /// In he, this message translates to:
  /// **'רישום משמרת'**
  String get add_shift_title;

  /// No description provided for @add_shift_edit_title.
  ///
  /// In he, this message translates to:
  /// **'עריכת משמרת'**
  String get add_shift_edit_title;

  /// No description provided for @add_shift_timer_tab.
  ///
  /// In he, this message translates to:
  /// **'טיימר'**
  String get add_shift_timer_tab;

  /// No description provided for @add_shift_manual_tab.
  ///
  /// In he, this message translates to:
  /// **'ידני'**
  String get add_shift_manual_tab;

  /// No description provided for @add_shift_paste_tab.
  ///
  /// In he, this message translates to:
  /// **'הדבקה'**
  String get add_shift_paste_tab;

  /// No description provided for @add_shift_timer_accumulated_live.
  ///
  /// In he, this message translates to:
  /// **'נצבר בשידור חי'**
  String get add_shift_timer_accumulated_live;

  /// No description provided for @add_shift_timer_countdown.
  ///
  /// In he, this message translates to:
  /// **'ספירה לאחור: '**
  String get add_shift_timer_countdown;

  /// No description provided for @add_shift_timer_break_paid.
  ///
  /// In he, this message translates to:
  /// **'בהפסקה בתשלום...'**
  String get add_shift_timer_break_paid;

  /// No description provided for @add_shift_timer_break_unpaid.
  ///
  /// In he, this message translates to:
  /// **'בהפסקה ללא תשלום (השעון עצר)'**
  String get add_shift_timer_break_unpaid;

  /// No description provided for @add_shift_timer_total_break_unpaid.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ הפסקה (לא בתשלום):'**
  String get add_shift_timer_total_break_unpaid;

  /// No description provided for @add_shift_timer_resume_work.
  ///
  /// In he, this message translates to:
  /// **'חזור לעבודה'**
  String get add_shift_timer_resume_work;

  /// No description provided for @add_shift_timer_stop_shift.
  ///
  /// In he, this message translates to:
  /// **'סיים משמרת'**
  String get add_shift_timer_stop_shift;

  /// No description provided for @add_shift_timer_start_shift.
  ///
  /// In he, this message translates to:
  /// **'התחל משמרת'**
  String get add_shift_timer_start_shift;

  /// No description provided for @add_shift_timer_continue_work.
  ///
  /// In he, this message translates to:
  /// **'המשך עבודה'**
  String get add_shift_timer_continue_work;

  /// No description provided for @add_shift_timer_stopped_msg.
  ///
  /// In he, this message translates to:
  /// **'הטיימר נעצר. האם ברצונך לשמור את המשמרת או להמשיך בעבודה?'**
  String get add_shift_timer_stopped_msg;

  /// No description provided for @add_shift_timer_reset_title.
  ///
  /// In he, this message translates to:
  /// **'איפוס טיימר'**
  String get add_shift_timer_reset_title;

  /// No description provided for @add_shift_timer_reset_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך לאפס את הטיימר? כל המידע הנוכחי יימחק.'**
  String get add_shift_timer_reset_desc;

  /// No description provided for @add_shift_timer_resume_shift.
  ///
  /// In he, this message translates to:
  /// **'המשך משמרת'**
  String get add_shift_timer_resume_shift;

  /// No description provided for @add_shift_manual_time_section.
  ///
  /// In he, this message translates to:
  /// **'זמן'**
  String get add_shift_manual_time_section;

  /// No description provided for @add_shift_manual_date_label.
  ///
  /// In he, this message translates to:
  /// **'תאריך'**
  String get add_shift_manual_date_label;

  /// No description provided for @add_shift_manual_start_time_label.
  ///
  /// In he, this message translates to:
  /// **'שעת התחלה'**
  String get add_shift_manual_start_time_label;

  /// No description provided for @add_shift_manual_end_time_label.
  ///
  /// In he, this message translates to:
  /// **'שעת סיום'**
  String get add_shift_manual_end_time_label;

  /// No description provided for @add_shift_manual_break_type_section.
  ///
  /// In he, this message translates to:
  /// **'סוג הפסקה'**
  String get add_shift_manual_break_type_section;

  /// No description provided for @add_shift_manual_no_break.
  ///
  /// In he, this message translates to:
  /// **'ללא'**
  String get add_shift_manual_no_break;

  /// No description provided for @add_shift_manual_paid_break.
  ///
  /// In he, this message translates to:
  /// **'בתשלום'**
  String get add_shift_manual_paid_break;

  /// No description provided for @add_shift_manual_unpaid_break.
  ///
  /// In he, this message translates to:
  /// **'ללא תשלום'**
  String get add_shift_manual_unpaid_break;

  /// No description provided for @add_shift_manual_work_tips_section.
  ///
  /// In he, this message translates to:
  /// **'עבודה וטיפים'**
  String get add_shift_manual_work_tips_section;

  /// No description provided for @add_shift_manual_job_type_label.
  ///
  /// In he, this message translates to:
  /// **'סוג עבודה'**
  String get add_shift_manual_job_type_label;

  /// No description provided for @add_shift_paste_title.
  ///
  /// In he, this message translates to:
  /// **'הדבקה חופשית'**
  String get add_shift_paste_title;

  /// No description provided for @add_shift_paste_default_job_label.
  ///
  /// In he, this message translates to:
  /// **'סוג עבודה ברירת מחדל'**
  String get add_shift_paste_default_job_label;

  /// No description provided for @add_shift_paste_format_info.
  ///
  /// In he, this message translates to:
  /// **'פורמט: DD.MM.YYYY - HH:mm - HH:mm [הפסקה] [+ tips]\nהפסקות: ללא / 20 דקות / 45 דקות'**
  String get add_shift_paste_format_info;

  /// No description provided for @add_shift_paste_hint.
  ///
  /// In he, this message translates to:
  /// **'הדבק משמרות כאן...\nלדוגמה:\n24.6.2026 - 17:30 - 23:00 45 דקות + 50'**
  String get add_shift_paste_hint;

  /// No description provided for @add_shift_paste_parse_button.
  ///
  /// In he, this message translates to:
  /// **'פענח ושמור הכל'**
  String get add_shift_paste_parse_button;

  /// No description provided for @add_shift_paste_parse_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'פענוח משמרות'**
  String get add_shift_paste_parse_dialog_title;

  /// No description provided for @add_shift_paste_parse_dialog_desc.
  ///
  /// In he, this message translates to:
  /// **'האם לפענח ולשמור משמרות מהטקסט שהודבק?'**
  String get add_shift_paste_parse_dialog_desc;

  /// No description provided for @add_shift_paste_error.
  ///
  /// In he, this message translates to:
  /// **'בדוק שוב שהפורמט שהזנת תקין'**
  String get add_shift_paste_error;

  /// No description provided for @add_shift_tips_title.
  ///
  /// In he, this message translates to:
  /// **'טיפים'**
  String get add_shift_tips_title;

  /// No description provided for @add_shift_tips_total.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ'**
  String get add_shift_tips_total;

  /// No description provided for @add_shift_tips_hint.
  ///
  /// In he, this message translates to:
  /// **'סכום טיפ'**
  String get add_shift_tips_hint;

  /// No description provided for @add_shift_tips_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף טיפ'**
  String get add_shift_tips_add_button;

  /// No description provided for @add_shift_expenses_title.
  ///
  /// In he, this message translates to:
  /// **'הוצאות למשמרת'**
  String get add_shift_expenses_title;

  /// No description provided for @add_shift_expenses_total.
  ///
  /// In he, this message translates to:
  /// **'סה\"כ'**
  String get add_shift_expenses_total;

  /// No description provided for @add_shift_expenses_add_button.
  ///
  /// In he, this message translates to:
  /// **'הוסף הוצאה'**
  String get add_shift_expenses_add_button;

  /// No description provided for @add_shift_shift_ended_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'שמירת משמרת'**
  String get add_shift_shift_ended_dialog_title;

  /// No description provided for @add_shift_shift_ended_dialog_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך לשמור את פרטי המשמרת?'**
  String get add_shift_shift_ended_dialog_desc;

  /// No description provided for @add_shift_shift_ended_edit_dialog_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך לשמור את פרטי המשמרת?'**
  String get add_shift_shift_ended_edit_dialog_desc;

  /// No description provided for @add_shift_shift_edit_dialog_title.
  ///
  /// In he, this message translates to:
  /// **'עדכון משמרת'**
  String get add_shift_shift_edit_dialog_title;

  /// No description provided for @add_shift_shift_saved.
  ///
  /// In he, this message translates to:
  /// **'המשמרת נשמרה בהצלחה'**
  String get add_shift_shift_saved;

  /// No description provided for @add_shift_pick_a_job.
  ///
  /// In he, this message translates to:
  /// **'בחר סוג עבודה קודם'**
  String get add_shift_pick_a_job;

  /// No description provided for @add_shift_delete_title.
  ///
  /// In he, this message translates to:
  /// **'מחיקת משמרת'**
  String get add_shift_delete_title;

  /// No description provided for @add_shift_delete_desc.
  ///
  /// In he, this message translates to:
  /// **'האם אתה בטוח שברצונך למחוק את המשמרת מיום'**
  String get add_shift_delete_desc;

  /// No description provided for @add_shift_delete_msg.
  ///
  /// In he, this message translates to:
  /// **'המשמרת נמחקה בהצלחה: '**
  String get add_shift_delete_msg;

  /// No description provided for @notification_reminder_title.
  ///
  /// In he, this message translates to:
  /// **'תזכורת למשמרת'**
  String get notification_reminder_title;

  /// No description provided for @notification_reminder_body.
  ///
  /// In he, this message translates to:
  /// **'המשמרת שלך ([[name]]) מתחילה בעוד [[time]]!'**
  String get notification_reminder_body;

  /// No description provided for @notification_channel_reminders_name.
  ///
  /// In he, this message translates to:
  /// **'תזכורות משמרת'**
  String get notification_channel_reminders_name;

  /// No description provided for @notification_channel_reminders_desc.
  ///
  /// In he, this message translates to:
  /// **'תזכורת לפני תחילת משמרת'**
  String get notification_channel_reminders_desc;

  /// No description provided for @notification_timer_channel_name.
  ///
  /// In he, this message translates to:
  /// **'משמרת פעילה'**
  String get notification_timer_channel_name;

  /// No description provided for @notification_timer_channel_desc.
  ///
  /// In he, this message translates to:
  /// **'מציג את זמן המשמרת הנוכחית'**
  String get notification_timer_channel_desc;

  /// No description provided for @notification_timer_title_active.
  ///
  /// In he, this message translates to:
  /// **'משמרת פעילה'**
  String get notification_timer_title_active;

  /// No description provided for @notification_timer_title_paid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה בתשלום'**
  String get notification_timer_title_paid_break;

  /// No description provided for @notification_timer_title_unpaid_break.
  ///
  /// In he, this message translates to:
  /// **'הפסקה ללא תשלום'**
  String get notification_timer_title_unpaid_break;

  /// No description provided for @notification_timer_body_running.
  ///
  /// In he, this message translates to:
  /// **'הטיימר רץ...'**
  String get notification_timer_body_running;

  /// No description provided for @notification_timer_body_countdown.
  ///
  /// In he, this message translates to:
  /// **'ספירה לאחור: [[time]]'**
  String get notification_timer_body_countdown;

  /// No description provided for @filter_title.
  ///
  /// In he, this message translates to:
  /// **'סינון משמרות'**
  String get filter_title;

  /// No description provided for @filter_clear_all.
  ///
  /// In he, this message translates to:
  /// **'נקה הכל'**
  String get filter_clear_all;

  /// No description provided for @filter_apply.
  ///
  /// In he, this message translates to:
  /// **'החל מסננים'**
  String get filter_apply;

  /// No description provided for @filter_wage_range.
  ///
  /// In he, this message translates to:
  /// **'טווח שכר כולל'**
  String get filter_wage_range;

  /// No description provided for @filter_tips_range.
  ///
  /// In he, this message translates to:
  /// **'טווח טיפים'**
  String get filter_tips_range;

  /// No description provided for @filter_expenses_range.
  ///
  /// In he, this message translates to:
  /// **'טווח הוצאות'**
  String get filter_expenses_range;

  /// No description provided for @filter_duration_range.
  ///
  /// In he, this message translates to:
  /// **'טווח זמן (שעות)'**
  String get filter_duration_range;

  /// No description provided for @filter_date_range.
  ///
  /// In he, this message translates to:
  /// **'טווח תאריכים'**
  String get filter_date_range;

  /// No description provided for @filter_job_type.
  ///
  /// In he, this message translates to:
  /// **'סוג עבודה'**
  String get filter_job_type;

  /// No description provided for @filter_min.
  ///
  /// In he, this message translates to:
  /// **'מינימום'**
  String get filter_min;

  /// No description provided for @filter_max.
  ///
  /// In he, this message translates to:
  /// **'מקסימום'**
  String get filter_max;

  /// No description provided for @filter_active_filters.
  ///
  /// In he, this message translates to:
  /// **'מסננים פעילים:'**
  String get filter_active_filters;

  /// No description provided for @filter_no_results.
  ///
  /// In he, this message translates to:
  /// **'אין משמרות התואמות למסננים אלו'**
  String get filter_no_results;

  /// No description provided for @filter_chip_wage.
  ///
  /// In he, this message translates to:
  /// **'שכר: [[min]] - [[max]]'**
  String get filter_chip_wage;

  /// No description provided for @filter_chip_tips.
  ///
  /// In he, this message translates to:
  /// **'טיפים: [[min]] - [[max]]'**
  String get filter_chip_tips;

  /// No description provided for @filter_chip_expenses.
  ///
  /// In he, this message translates to:
  /// **'הוצאות: [[min]] - [[max]]'**
  String get filter_chip_expenses;

  /// No description provided for @filter_chip_duration.
  ///
  /// In he, this message translates to:
  /// **'זמן: [[min]] - [[max]] שעות'**
  String get filter_chip_duration;

  /// No description provided for @filter_chip_date.
  ///
  /// In he, this message translates to:
  /// **'תאריך: [[start]] - [[end]]'**
  String get filter_chip_date;

  /// No description provided for @filter_chip_job.
  ///
  /// In he, this message translates to:
  /// **'עבודה: [[name]]'**
  String get filter_chip_job;

  /// No description provided for @filter_empty_state_title.
  ///
  /// In he, this message translates to:
  /// **'אין משמרות תואמות'**
  String get filter_empty_state_title;

  /// No description provided for @filter_empty_state_subtitle.
  ///
  /// In he, this message translates to:
  /// **'נסה לשנות את המסננים כדי לראות תוצאות'**
  String get filter_empty_state_subtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
