/// Masks long digit sequences (8 or more digits) like card numbers,
/// phone numbers, and business registration numbers with '*' before sending OCR text to Gemini.
/// WHY: Protects user privacy per Section 5 of the project instructions.
String maskSensitiveText(String text) {
  // Matches sequences of digits (possibly separated by dashes or spaces) that contain 8 or more digits.
  final digitRunRegExp = RegExp(r'\b(?:\d[ -]*){8,}\b');
  return text.replaceAllMapped(digitRunRegExp, (match) {
    final matchedStr = match.group(0) ?? '';
    return matchedStr.replaceAll(RegExp(r'\d'), '*');
  });
}
