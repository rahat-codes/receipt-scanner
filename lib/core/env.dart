import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get geminiModel => dotenv.env['GEMINI_MODEL'] ?? 'gemini-flash-latest';
  static String get geminiBaseUrl => dotenv.env['GEMINI_BASE_URL'] ?? 'https://generativelanguage.googleapis.com/v1beta';
  static int get geminiTimeoutSeconds => int.tryParse(dotenv.env['GEMINI_TIMEOUT_SECONDS'] ?? '8') ?? 8;
  static double get llmFallbackThreshold => double.tryParse(dotenv.env['LLM_FALLBACK_THRESHOLD'] ?? '0.70') ?? 0.70;
}
