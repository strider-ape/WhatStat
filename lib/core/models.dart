/// Message types in WhatsApp chat
enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  sticker,
  gif,
  location,
  contact,
  deleted,
  system,
  poll,
  link,
}

/// A single message in the chat
class Message {
  final String id;
  final DateTime timestamp;
  final String sender;
  final String content;
  final MessageType type;
  final List<String> emojis;
  final int wordCount;
  final int characterCount;
  final bool isReply;

  const Message({
    required this.id,
    required this.timestamp,
    required this.sender,
    required this.content,
    this.type = MessageType.text,
    this.emojis = const [],
    this.wordCount = 0,
    this.characterCount = 0,
    this.isReply = false,
  });

  Message copyWith({
    String? id,
    DateTime? timestamp,
    String? sender,
    String? content,
    MessageType? type,
    List<String>? emojis,
    int? wordCount,
    int? characterCount,
    bool? isReply,
  }) {
    return Message(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      type: type ?? this.type,
      emojis: emojis ?? this.emojis,
      wordCount: wordCount ?? this.wordCount,
      characterCount: characterCount ?? this.characterCount,
      isReply: isReply ?? this.isReply,
    );
  }
}

/// A participant in the chat
class Participant {
  final String name;
  final int messageCount;
  final int wordCount;
  final int emojiCount;
  final int mediaCount;
  final DateTime? firstMessage;
  final DateTime? lastMessage;
  final Map<String, int> emojiUsage;

  const Participant({
    required this.name,
    this.messageCount = 0,
    this.wordCount = 0,
    this.emojiCount = 0,
    this.mediaCount = 0,
    this.firstMessage,
    this.lastMessage,
    this.emojiUsage = const {},
  });

  Participant copyWith({
    String? name,
    int? messageCount,
    int? wordCount,
    int? emojiCount,
    int? mediaCount,
    DateTime? firstMessage,
    DateTime? lastMessage,
    Map<String, int>? emojiUsage,
  }) {
    return Participant(
      name: name ?? this.name,
      messageCount: messageCount ?? this.messageCount,
      wordCount: wordCount ?? this.wordCount,
      emojiCount: emojiCount ?? this.emojiCount,
      mediaCount: mediaCount ?? this.mediaCount,
      firstMessage: firstMessage ?? this.firstMessage,
      lastMessage: lastMessage ?? this.lastMessage,
      emojiUsage: emojiUsage ?? this.emojiUsage,
    );
  }
}

/// A complete parsed chat file
class ChatData {
  final String id;
  final String fileName;
  final DateTime importedAt;
  final DateTime? chatStartDate;
  final DateTime? chatEndDate;
  final int totalMessages;
  final List<Participant> participants;
  final List<Message> messages;
  final String? chatName;
  final bool isGroupChat;

  const ChatData({
    required this.id,
    required this.fileName,
    required this.importedAt,
    this.chatStartDate,
    this.chatEndDate,
    this.totalMessages = 0,
    this.participants = const [],
    this.messages = const [],
    this.chatName,
    this.isGroupChat = false,
  });

  int get participantCount => participants.length;
  
  int get totalWords => messages.fold(0, (sum, m) => sum + m.wordCount);
  
  int get totalEmojis => messages.fold(0, (sum, m) => sum + m.emojis.length);
  
  int get totalMedia => messages.where((m) => 
    m.type == MessageType.image || 
    m.type == MessageType.video || 
    m.type == MessageType.audio ||
    m.type == MessageType.document ||
    m.type == MessageType.sticker ||
    m.type == MessageType.gif
  ).length;

  Duration get chatDuration {
    if (chatStartDate == null || chatEndDate == null) return Duration.zero;
    return chatEndDate!.difference(chatStartDate!);
  }

  double get averageMessagesPerDay {
    if (chatDuration.inDays == 0) return totalMessages.toDouble();
    return totalMessages / chatDuration.inDays;
  }
}
