enum MessageSender { user, ai }

class ChatMessageModel {
  final String id;
  final String message;
  final MessageSender sender;
  final DateTime timestamp;
  final bool consumedToken;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    this.consumedToken = false,
  });

  ChatMessageModel copyWith({
    String? id,
    String? message,
    MessageSender? sender,
    DateTime? timestamp,
    bool? consumedToken,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      consumedToken: consumedToken ?? this.consumedToken,
    );
  }
}

class SuggestedPrompt {
  final String id;
  final String text;
  final String category;

  SuggestedPrompt({
    required this.id,
    required this.text,
    required this.category,
  });

  static List<SuggestedPrompt> getDefaultPrompts() {
    return [
      SuggestedPrompt(
        id: '1',
        text: 'Generate tax report',
        category: 'Reports',
      ),
      SuggestedPrompt(
        id: '2',
        text: 'Show suspicious invoices',
        category: 'Analysis',
      ),
      SuggestedPrompt(
        id: '3',
        text: 'Summary of this month',
        category: 'Reports',
      ),
      SuggestedPrompt(
        id: '4',
        text: 'Top 5 vendors by spend',
        category: 'Analysis',
      ),
    ];
  }
}