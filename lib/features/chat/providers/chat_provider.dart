import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message_model.dart';
import '../../auth/providers/auth_provider.dart';

class ChatNotifier extends StateNotifier<List<ChatMessageModel>> {
  final Ref ref;

  ChatNotifier(this.ref) : super([
    ChatMessageModel(
      id: const Uuid().v4(),
      message: 'Hello! I\'m your Invoice AI assistant. How can I help you today?',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      consumedToken: false,
    ),
  ]);

  Future<void> sendMessage(String message) async {
    final uuid = const Uuid();

    // Add user message
    final userMessage = ChatMessageModel(
      id: uuid.v4(),
      message: message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      consumedToken: false,
    );

    state = [...state, userMessage];

    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 1));

    // Consume token
    ref.read(authProvider.notifier).consumeToken();

    // Generate mock AI response based on user message
    final aiResponse = _generateAIResponse(message);

    final aiMessage = ChatMessageModel(
      id: uuid.v4(),
      message: aiResponse,
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      consumedToken: true,
    );

    state = [...state, aiMessage];
  }

  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('tax') || lowerMessage.contains('report')) {
      return 'I\'ve analyzed your invoices. Here\'s your tax summary:\n\n'
          '• Total Tax Paid: \$543.00\n'
          '• Average Tax Rate: 15%\n'
          '• Tax by Category:\n'
          '  - Medical: \$127.50\n'
          '  - Goods: \$367.50\n'
          '  - Services: \$48.00\n\n'
          'Would you like me to generate a detailed PDF report?';
    } else if (lowerMessage.contains('suspicious') || lowerMessage.contains('fraud')) {
      return 'I found 1 invoice flagged for review:\n\n'
          '• Tech Supplies Inc - \$2,817.50\n'
          '  Risk: HIGH\n'
          '  Reason: Unusual amount for this vendor\n\n'
          'Would you like to view the details?';
    } else if (lowerMessage.contains('month') || lowerMessage.contains('summary')) {
      return 'Monthly Summary:\n\n'
          '• Total Invoices: 125\n'
          '• Total Amount: \$45,230.00\n'
          '• Average per Invoice: \$361.84\n'
          '• Top Vendor: Tech Supplies Inc\n'
          '• Most Common Type: Goods (45%)\n\n'
          'Compared to last month, spending is up 12%.';
    } else if (lowerMessage.contains('vendor')) {
      return 'Top 5 Vendors by Spend:\n\n'
          '1. Tech Supplies Inc - \$12,450\n'
          '2. City Hospital - \$8,320\n'
          '3. Office Depot - \$6,780\n'
          '4. Clean Pro Services - \$4,210\n'
          '5. Energy Corp - \$3,890\n\n'
          'Would you like to see detailed breakdowns?';
    } else {
      return 'I can help you with:\n\n'
          '• Generate tax reports\n'
          '• Identify suspicious invoices\n'
          '• View monthly summaries\n'
          '• Analyze vendor spending\n'
          '• Search specific invoices\n\n'
          'What would you like to know?';
    }
  }

  void clearChat() {
    state = [
      ChatMessageModel(
        id: const Uuid().v4(),
        message: 'Chat cleared. How can I help you today?',
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
        consumedToken: false,
      ),
    ];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessageModel>>((ref) {
  return ChatNotifier(ref);
});