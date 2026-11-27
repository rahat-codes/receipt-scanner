// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Receipt Scanner';

  @override
  String get scanReceipt => 'Scan receipt';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get receiptsTitle => 'Receipts';

  @override
  String get statsTitle => 'Stats';

  @override
  String get settingsTitle => 'Settings';

  @override
  String receiptCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receipts',
      one: '1 receipt',
    );
    return '$_temp0';
  }

  @override
  String get emptyTitle => 'No receipts yet';

  @override
  String get emptyBody => 'Scan your first receipt to start tracking.';

  @override
  String get reading => 'Reading text...';

  @override
  String get findingTotal => 'Finding the total...';

  @override
  String get askingAi => 'Asking AI to double-check...';

  @override
  String get merchant => 'Merchant';

  @override
  String get date => 'Date';

  @override
  String get total => 'Total';

  @override
  String get currency => 'Currency';

  @override
  String get category => 'Category';

  @override
  String get saveReceipt => 'Save receipt';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get deleteReceipt => 'Delete receipt';

  @override
  String get deleteConfirm => 'Delete this receipt? This can\'t be undone.';

  @override
  String get checkThis => 'Check this: it may be wrong.';

  @override
  String get unreadable => 'We couldn\'t read this receipt. Enter the details below.';

  @override
  String get unknownMerchant => 'Unknown merchant';

  @override
  String get badgeAuto => 'Auto';

  @override
  String get badgeAi => 'AI-assisted';

  @override
  String get badgeEdited => 'Edited';

  @override
  String get aiUnavailable => 'AI check unavailable. Please review the fields.';

  @override
  String get permissionCamera => 'Allow camera access to scan receipts.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get noReceiptsMonth => 'No receipts in this month.';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get aiDoubleCheck => 'AI double-check';

  @override
  String get aiDoubleCheckHelp => 'When on, text from receipts the app can\'t read confidently is sent to Google\'s Gemini API. Photos are never sent. Card and phone numbers are hidden first.';

  @override
  String totalThisMonth(String month) {
    return '$month total';
  }

  @override
  String get category_food => 'Food and drinks';

  @override
  String get category_groceries => 'Groceries';

  @override
  String get category_transport => 'Transport';

  @override
  String get category_shopping => 'Shopping';

  @override
  String get category_health => 'Health';

  @override
  String get category_entertainment => 'Entertainment';

  @override
  String get category_utilities => 'Bills and utilities';

  @override
  String get category_other => 'Other';

  @override
  String get system => 'System';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get undo => 'Undo';

  @override
  String get receiptDeleted => 'Receipt deleted';

  @override
  String get discardTitle => 'Discard this receipt?';

  @override
  String get notes => 'Notes';
}
