import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
enum MessageSender {
  @HiveField(0)
  user,
  @HiveField(1)
  bot,
  @HiveField(2)
  system
}

@HiveType(typeId: 1)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  hospitalCard,
  @HiveField(2)
  emergencyAlert
}

@HiveType(typeId: 2)
class ChatMessage {
  @HiveField(0)
  final String content;
  @HiveField(1)
  final MessageSender sender;
  @HiveField(2)
  final MessageType messageType;
  @HiveField(3)
  final DateTime timestamp;
  @HiveField(4)
  final String? actionCommand;
  @HiveField(5)
  final int? countdownSeconds;

  ChatMessage({
    required this.content,
    required this.sender,
    this.messageType = MessageType.text,
    required this.timestamp,
    this.actionCommand,
    this.countdownSeconds,
  });
}
