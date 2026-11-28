abstract class AssistantService {
  Future<String> sendMessage(String prompt, List<Map<String, String>> history);
}
