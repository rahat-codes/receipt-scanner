import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt Scanner'**
  String get appTitle;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceipt;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @receiptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get receiptsTitle;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @receiptCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 receipt} other{{count} receipts}}'**
  String receiptCount(num count);

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No receipts yet'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Scan your first receipt to start tracking.'**
  String get emptyBody;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading text...'**
  String get reading;

  /// No description provided for @findingTotal.
  ///
  /// In en, this message translates to:
  /// **'Finding the total...'**
  String get findingTotal;

  /// No description provided for @askingAi.
  ///
  /// In en, this message translates to:
  /// **'Asking AI to double-check...'**
  String get askingAi;

  /// No description provided for @merchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchant;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @saveReceipt.
  ///
  /// In en, this message translates to:
  /// **'Save receipt'**
  String get saveReceipt;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @deleteReceipt.
  ///
  /// In en, this message translates to:
  /// **'Delete receipt'**
  String get deleteReceipt;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this receipt? This can\'t be undone.'**
  String get deleteConfirm;

  /// No description provided for @checkThis.
  ///
  /// In en, this message translates to:
  /// **'Check this: it may be wrong.'**
  String get checkThis;

  /// No description provided for @unreadable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read this receipt. Enter the details below.'**
  String get unreadable;

  /// No description provided for @unknownMerchant.
  ///
  /// In en, this message translates to:
  /// **'Unknown merchant'**
  String get unknownMerchant;

  /// No description provided for @badgeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get badgeAuto;

  /// No description provided for @badgeAi.
  ///
  /// In en, this message translates to:
  /// **'AI-assisted'**
  String get badgeAi;

  /// No description provided for @badgeEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get badgeEdited;

  /// No description provided for @aiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'AI check unavailable. Please review the fields.'**
  String get aiUnavailable;

  /// No description provided for @permissionCamera.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to scan receipts.'**
  String get permissionCamera;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @noReceiptsMonth.
  ///
  /// In en, this message translates to:
  /// **'No receipts in this month.'**
  String get noReceiptsMonth;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @privacyDetail.
  ///
  /// In en, this message translates to:
  /// **'Receipt photos and spending data stay on this device. No data is uploaded to external servers.'**
  String get privacyDetail;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all receipts, rules, and assistant data? This cannot be undone.'**
  String get deleteAllDataConfirm;

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted'**
  String get allDataDeleted;

  /// No description provided for @lastSixMonths.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get lastSixMonths;

  /// No description provided for @receiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receipt not found'**
  String get receiptNotFound;

  /// No description provided for @askAboutSpending.
  ///
  /// In en, this message translates to:
  /// **'Ask about your spending...'**
  String get askAboutSpending;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable AI Assistant?'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'Questions and necessary spending numbers (amounts, dates, and up to 10 merchant names per answer) are sent to Google\'s Gemini API. Photos, raw receipt text and item names are never sent. On the free tier, Google may use submitted content to improve its products and human reviewers may read it. Do not submit real personal data. This demo uses test data. This demo is for testing only and is not offered to users in the EEA, Switzerland or the UK.\n\nSee https://ai.google.dev/gemini-api/terms'**
  String get consentBody;

  /// No description provided for @agreeAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get agreeAndContinue;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @aiAssistantSetting.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistantSetting;

  /// No description provided for @aiAssistantHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask questions about your spending in plain language.'**
  String get aiAssistantHelp;

  /// No description provided for @askAssistantHint.
  ///
  /// In en, this message translates to:
  /// **'Type a question about your spending...'**
  String get askAssistantHint;

  /// No description provided for @offlineAssistantFallback.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what I can tell without AI:'**
  String get offlineAssistantFallback;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes. Not financial advice.'**
  String get disclaimer;

  /// No description provided for @chipThisMonthTotal.
  ///
  /// In en, this message translates to:
  /// **'This month\'s total'**
  String get chipThisMonthTotal;

  /// No description provided for @chipTopCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category this month'**
  String get chipTopCategory;

  /// No description provided for @chipQ1.
  ///
  /// In en, this message translates to:
  /// **'How much did I spend this month?'**
  String get chipQ1;

  /// No description provided for @chipQ2.
  ///
  /// In en, this message translates to:
  /// **'Which category costs me the most?'**
  String get chipQ2;

  /// No description provided for @chipQ3.
  ///
  /// In en, this message translates to:
  /// **'Compare this month with last month'**
  String get chipQ3;

  /// No description provided for @chipQ4.
  ///
  /// In en, this message translates to:
  /// **'What was my biggest purchase?'**
  String get chipQ4;

  /// No description provided for @aiDoubleCheck.
  ///
  /// In en, this message translates to:
  /// **'AI double-check'**
  String get aiDoubleCheck;

  /// No description provided for @aiDoubleCheckHelp.
  ///
  /// In en, this message translates to:
  /// **'When on, text from receipts the app can\'t read confidently is sent to Google\'s Gemini API. Photos are never sent. Card and phone numbers are hidden first.'**
  String get aiDoubleCheckHelp;

  /// No description provided for @totalThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{month} total'**
  String totalThisMonth(String month);

  /// No description provided for @category_food.
  ///
  /// In en, this message translates to:
  /// **'Food and drinks'**
  String get category_food;

  /// No description provided for @category_groceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get category_groceries;

  /// No description provided for @category_transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get category_transport;

  /// No description provided for @category_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get category_shopping;

  /// No description provided for @category_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get category_health;

  /// No description provided for @category_entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get category_entertainment;

  /// No description provided for @category_utilities.
  ///
  /// In en, this message translates to:
  /// **'Bills and utilities'**
  String get category_utilities;

  /// No description provided for @category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_other;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @receiptDeleted.
  ///
  /// In en, this message translates to:
  /// **'Receipt deleted'**
  String get receiptDeleted;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this receipt?'**
  String get discardTitle;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
