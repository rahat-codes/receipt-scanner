import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../domain/entities/money.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class AssistantState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  const AssistantState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AssistantController extends StateNotifier<AssistantState> {
  final Ref ref;

  AssistantController(this.ref) : super(const AssistantState());

  Future<void> sendMessage(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    // WHY: Cap user message length at 500 characters to prevent API prompt flooding.
    final cappedPrompt = trimmed.length > 500 ? trimmed.substring(0, 500) : trimmed;

    final userMsg = ChatMessage(text: cappedPrompt, isUser: true, timestamp: DateTime.now());
    // WHY: Set isLoading = true synchronously before any await to prevent double submissions.
    state = state.copyWith(messages: [...state.messages, userMsg], isLoading: true, errorMessage: null);

    try {
      final assistantService = ref.read(assistantServiceProvider);
      // WHY: Cap history at last 6 turns (3 user, 3 model) to keep token usage bounded.
      final historyMsgs = state.messages.take(state.messages.length - 1).toList();
      final boundedHistory = historyMsgs.length > 6
          ? historyMsgs.sublist(historyMsgs.length - 6)
          : historyMsgs;

      final history = boundedHistory
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'text': m.text})
          .toList();

      final reply = await assistantService.sendMessage(cappedPrompt, history);

      final botMsg = ChatMessage(text: reply, isUser: false, timestamp: DateTime.now());
      state = state.copyWith(messages: [...state.messages, botMsg], isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to reach AI assistant. Please check your network or API key.',
      );
    }
  }

  Future<void> answerQuickChip(String chipType, String currency, String locale) async {
    final repo = ref.read(receiptRepositoryProvider);
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final receipts = await repo.getMonthReceipts(startOfMonth, currency);
    final filtered = receipts.where((r) => !r.purchasedAt.isBefore(startOfMonth) && r.purchasedAt.isBefore(nextMonth));

    if (chipType == 'this_month_total') {
      int total = filtered.fold(0, (sum, r) => sum + r.totalMinor);
      final formatted = Money(total, currency: currency).format(locale);
      final answer = locale.startsWith('ko') ? '이번 달 총 지출은 $formatted 입니다.' : 'This month total spending is $formatted.';

      state = state.copyWith(messages: [
        ...state.messages,
        ChatMessage(text: 'This month\'s total', isUser: true, timestamp: DateTime.now()),
        ChatMessage(text: answer, isUser: false, timestamp: DateTime.now()),
      ]);
    } else if (chipType == 'top_category') {
      final categories = await repo.getCategories();
      final catMap = {for (var c in categories) c.id: c.key};
      final catTotals = <int, int>{};
      for (final r in filtered) {
        catTotals[r.categoryId] = (catTotals[r.categoryId] ?? 0) + r.totalMinor;
      }
      if (catTotals.isEmpty) {
        final answer = locale.startsWith('ko') ? '이번 달 지출 기록이 없어요.' : 'No spending records for this month.';
        state = state.copyWith(messages: [
          ...state.messages,
          ChatMessage(text: 'Top category this month', isUser: true, timestamp: DateTime.now()),
          ChatMessage(text: answer, isUser: false, timestamp: DateTime.now()),
        ]);
        return;
      }

      final topCatId = catTotals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final topCatKey = catMap[topCatId] ?? 'other';
      final topAmt = Money(catTotals[topCatId]!, currency: currency).format(locale);
      final answer = locale.startsWith('ko')
          ? '이번 달 가장 많이 지출한 분야는 $topCatKey ($topAmt)입니다.'
          : 'Top spending category this month is $topCatKey ($topAmt).';

      state = state.copyWith(messages: [
        ...state.messages,
        ChatMessage(text: 'Top category this month', isUser: true, timestamp: DateTime.now()),
        ChatMessage(text: answer, isUser: false, timestamp: DateTime.now()),
      ]);
    }
  }

  void clearChat() {
    state = const AssistantState();
  }
}

final assistantControllerProvider = StateNotifierProvider<AssistantController, AssistantState>((ref) {
  return AssistantController(ref);
});
