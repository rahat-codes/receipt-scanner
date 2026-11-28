// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '영수증 스캐너';

  @override
  String get scanReceipt => '영수증 스캔';

  @override
  String get takePhoto => '사진 촬영';

  @override
  String get chooseFromGallery => '갤러리에서 선택';

  @override
  String get receiptsTitle => '영수증';

  @override
  String get statsTitle => '통계';

  @override
  String get settingsTitle => '설정';

  @override
  String receiptCount(num count) {
    return '영수증 $count건';
  }

  @override
  String get emptyTitle => '아직 영수증이 없어요';

  @override
  String get emptyBody => '첫 영수증을 스캔해서 지출을 기록해 보세요.';

  @override
  String get reading => '글자를 읽는 중...';

  @override
  String get findingTotal => '합계를 찾는 중...';

  @override
  String get askingAi => 'AI가 다시 확인하는 중...';

  @override
  String get merchant => '상호';

  @override
  String get date => '날짜';

  @override
  String get total => '합계';

  @override
  String get currency => '통화';

  @override
  String get category => '카테고리';

  @override
  String get saveReceipt => '영수증 저장';

  @override
  String get discard => '취소';

  @override
  String get keepEditing => '계속 수정';

  @override
  String get deleteReceipt => '영수증 삭제';

  @override
  String get deleteConfirm => '이 영수증을 삭제할까요? 되돌릴 수 없어요.';

  @override
  String get checkThis => '확인해 주세요. 틀릴 수 있어요.';

  @override
  String get unreadable => '영수증을 읽지 못했어요. 아래에 직접 입력해 주세요.';

  @override
  String get unknownMerchant => '알 수 없는 상호';

  @override
  String get badgeAuto => '자동';

  @override
  String get badgeAi => 'AI 보조';

  @override
  String get badgeEdited => '수정됨';

  @override
  String get aiUnavailable => 'AI 확인을 사용할 수 없어요. 항목을 확인해 주세요.';

  @override
  String get permissionCamera => '영수증을 스캔하려면 카메라 접근을 허용해 주세요.';

  @override
  String get openSettings => '설정 열기';

  @override
  String get noReceiptsMonth => '이달에는 영수증이 없어요.';

  @override
  String get language => '언어';

  @override
  String get appearance => '화면 모드';

  @override
  String get privacy => '개인정보 보호';

  @override
  String get privacyDetail => '영수증 사진과 지출 정보는 이 기기에만 저장됩니다. 외부 서버로 전송되지 않습니다.';

  @override
  String get deleteAllData => '모든 데이터 삭제';

  @override
  String get deleteAllDataConfirm => '모든 영수증, 규칙 및 어시스턴트 데이터를 삭제할까요? 되돌릴 수 없습니다.';

  @override
  String get allDataDeleted => '모든 데이터가 삭제되었습니다';

  @override
  String get lastSixMonths => '최근 6개월';

  @override
  String get receiptNotFound => '영수증을 찾을 수 없어요';

  @override
  String get askAboutSpending => '지출에 대해 질문해 보세요...';

  @override
  String get consentTitle => 'AI 어시스턴트를 사용할까요?';

  @override
  String get consentBody => '질문과 필요한 지출 데이터(금액, 날짜, 답변당 최대 10개의 상호명)가 Google Gemini API로 전송됩니다. 사진, 원본 영수증 텍스트 및 품목명은 절대 전송되지 않습니다. 무료 티어에서는 Google이 제품 개선을 위해 제출된 컨텐츠를 사용할 수 있으며 인간 검토자가 읽을 수 있습니다. 실제 개인정보를 제출하지 마세요. 본 데모는 테스트 데이터를 사용합니다. 본 데모는 테스트 목적이며 EEA, 스위스 또는 영국의 사용자에게는 제공되지 않습니다.\n\n참고: https://ai.google.dev/gemini-api/terms';

  @override
  String get agreeAndContinue => '동의하고 계속하기';

  @override
  String get notNow => '나중에';

  @override
  String get aiAssistantSetting => 'AI 어시스턴트';

  @override
  String get aiAssistantHelp => '지출에 대해 대화형으로 질문하고 답변을 받아요.';

  @override
  String get askAssistantHint => '지출에 대해 궁금한 점을 물어보세요...';

  @override
  String get offlineAssistantFallback => 'AI 없이 확인할 수 있는 내용이에요:';

  @override
  String get clearChat => '대화 지우기';

  @override
  String get disclaimer => 'AI는 실수를 할 수 있어요. 투자 및 재무 자문이 아닙니다.';

  @override
  String get chipThisMonthTotal => '이번 달 총 지출';

  @override
  String get chipTopCategory => '이번 달 가장 많이 쓴 분야';

  @override
  String get chipQ1 => '이번 달에 얼마를 썼나요?';

  @override
  String get chipQ2 => '어떤 카테고리에 가장 많이 지출했나요?';

  @override
  String get chipQ3 => '이번 달과 지난달을 비교해 주세요';

  @override
  String get chipQ4 => '가장 큰 지출은 무엇인가요?';

  @override
  String get aiDoubleCheck => 'AI 재확인';

  @override
  String get aiDoubleCheckHelp => '확인이 어려운 영수증의 텍스트만 Google Gemini API로 전송해요. 사진은 전송하지 않으며, 카드·전화번호는 먼저 가려요.';

  @override
  String totalThisMonth(String month) {
    return '$month 합계';
  }

  @override
  String get category_food => '식비';

  @override
  String get category_groceries => '장보기';

  @override
  String get category_transport => '교통';

  @override
  String get category_shopping => '쇼핑';

  @override
  String get category_health => '건강';

  @override
  String get category_entertainment => '여가';

  @override
  String get category_utilities => '공과금';

  @override
  String get category_other => 'Other';

  @override
  String get system => '시스템';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get cancel => '취소';

  @override
  String get edit => '수정';

  @override
  String get undo => '실행 취소';

  @override
  String get receiptDeleted => '영수증이 삭제되었습니다';

  @override
  String get discardTitle => '이 영수증을 파기할까요?';

  @override
  String get notes => '메모';
}
