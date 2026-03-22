// ignore_for_file: constant_identifier_names

enum MessageSender {
  user,
  bot,
  system
}

enum MessageType {
  text,
  hospitalCard,
  emergencyAlert
}

class ChatMessage {
  final String content;
  final MessageSender sender;
  final MessageType messageType;
  final DateTime timestamp;
  final String? actionCommand;
  final int? countdownSeconds;

  ChatMessage({
    required this.content,
    required this.sender,
    this.messageType = MessageType.text,
    required this.timestamp,
    this.actionCommand,
    this.countdownSeconds,
  });

  // Hive 등 연동을 위한 Factory 메서드는 추후 추가 예정입니다.
}
