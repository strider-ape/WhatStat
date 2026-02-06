import 'package:uuid/uuid.dart';
import '../core/models.dart';
import '../core/utils.dart';

/// WhatsApp chat parser that handles multiple export formats
class WhatsAppParser {
  static const _uuid = Uuid();

  // Common WhatsApp date/time patterns
  static final List<RegExp> _patterns = [
    // Android format: "DD/MM/YY, HH:MM - Sender: Message"
    RegExp(r'^(\d{1,2}/\d{1,2}/\d{2,4}),?\s+(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AP]M)?)\s*[-–]\s*(.+?):\s*(.*)$', caseSensitive: false),
    // iOS format: "[DD/MM/YY, HH:MM:SS] Sender: Message"
    RegExp(r'^\[(\d{1,2}/\d{1,2}/\d{2,4}),?\s+(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AP]M)?)\]\s*(.+?):\s*(.*)$', caseSensitive: false),
    // Alternative: "DD-MM-YYYY HH:MM - Sender: Message"
    RegExp(r'^(\d{1,2}[-/.]\d{1,2}[-/.]\d{2,4}),?\s+(\d{1,2}:\d{2}(?::\d{2})?(?:\s*[AP]M)?)\s*[-–]\s*(.+?):\s*(.*)$', caseSensitive: false),
    // US format: "M/D/YY, H:MM PM - Sender: Message"
    RegExp(r'^(\d{1,2}/\d{1,2}/\d{2,4}),?\s+(\d{1,2}:\d{2}(?:\s*[AP]M))\s*[-–]\s*(.+?):\s*(.*)$', caseSensitive: false),
  ];

  // System message patterns
  static final List<RegExp> _systemPatterns = [
    RegExp(r'messages and calls are end-to-end encrypted', caseSensitive: false),
    RegExp(r'created group', caseSensitive: false),
    RegExp(r'added you', caseSensitive: false),
    RegExp(r'left$', caseSensitive: false),
    RegExp(r'removed', caseSensitive: false),
    RegExp(r"changed the group's icon", caseSensitive: false),
    RegExp(r"changed this group's icon", caseSensitive: false),
    RegExp(r'changed the subject', caseSensitive: false),
    RegExp(r"changed the group description", caseSensitive: false),
    RegExp(r'is now an admin', caseSensitive: false),
    RegExp(r'security code changed', caseSensitive: false),
    RegExp(r'missed.*call', caseSensitive: false),
    RegExp(r'started a call', caseSensitive: false),
  ];

  // Media message indicators
  static final Map<RegExp, MessageType> _mediaPatterns = {
    RegExp(r'<Media omitted>|<image omitted>|image omitted', caseSensitive: false): MessageType.image,
    RegExp(r'<video omitted>|video omitted', caseSensitive: false): MessageType.video,
    RegExp(r'<audio omitted>|audio omitted', caseSensitive: false): MessageType.audio,
    RegExp(r'<document omitted>|document omitted', caseSensitive: false): MessageType.document,
    RegExp(r'<sticker omitted>|sticker omitted', caseSensitive: false): MessageType.sticker,
    RegExp(r'<GIF omitted>|GIF omitted|<gif omitted>', caseSensitive: false): MessageType.gif,
    RegExp(r'<Contact card omitted>|contact card omitted', caseSensitive: false): MessageType.contact,
    RegExp(r'location:', caseSensitive: false): MessageType.location,
    RegExp(r'this message was deleted|you deleted this message', caseSensitive: false): MessageType.deleted,
  };

  /// Parse WhatsApp chat export text
  static ChatData parse(String content, String fileName) {
    final lines = content.split('\n');
    final messages = <Message>[];
    final participantsMap = <String, _ParticipantBuilder>{};
    
    String? currentSender;
    DateTime? currentTimestamp;
    StringBuffer currentContent = StringBuffer();
    
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;
      
      // Try to match message patterns
      Match? match;
      for (final pattern in _patterns) {
        match = pattern.firstMatch(line);
        if (match != null) break;
      }
      
      if (match != null) {
        // Save previous message if exists
        if (currentSender != null && currentTimestamp != null) {
          final msg = _createMessage(
            currentTimestamp,
            currentSender,
            currentContent.toString().trim(),
          );
          if (msg != null) {
            messages.add(msg);
            _updateParticipant(participantsMap, msg);
          }
        }
        
        // Parse new message
        final dateStr = match.group(1)!;
        final timeStr = match.group(2)!;
        currentSender = match.group(3)!.trim();
        currentContent = StringBuffer(match.group(4) ?? '');
        currentTimestamp = _parseDateTime(dateStr, timeStr);
      } else if (currentSender != null) {
        // Continuation of previous message
        currentContent.writeln();
        currentContent.write(line);
      }
    }
    
    // Don't forget the last message
    if (currentSender != null && currentTimestamp != null) {
      final msg = _createMessage(
        currentTimestamp,
        currentSender,
        currentContent.toString().trim(),
      );
      if (msg != null) {
        messages.add(msg);
        _updateParticipant(participantsMap, msg);
      }
    }
    
    // Build participants list
    final participants = participantsMap.values
        .map((b) => b.build())
        .toList()
      ..sort((a, b) => b.messageCount.compareTo(a.messageCount));
    
    // Determine if group chat
    final isGroupChat = participants.length > 2;
    
    // Extract chat name from filename
    String? chatName;
    if (fileName.contains('WhatsApp Chat with ')) {
      chatName = fileName
          .replaceFirst('WhatsApp Chat with ', '')
          .replaceAll('.txt', '')
          .replaceAll('.zip', '');
    }
    
    return ChatData(
      id: _uuid.v4(),
      fileName: fileName,
      importedAt: DateTime.now(),
      chatStartDate: messages.isNotEmpty ? messages.first.timestamp : null,
      chatEndDate: messages.isNotEmpty ? messages.last.timestamp : null,
      totalMessages: messages.length,
      participants: participants,
      messages: messages,
      chatName: chatName,
      isGroupChat: isGroupChat,
    );
  }

  static DateTime? _parseDateTime(String dateStr, String timeStr) {
    try {
      // Normalize separators
      dateStr = dateStr.replaceAll('-', '/').replaceAll('.', '/');
      
      final dateParts = dateStr.split('/');
      if (dateParts.length != 3) return null;
      
      int day, month, year;
      
      // Detect date format (DD/MM/YY vs MM/DD/YY)
      final first = int.parse(dateParts[0]);
      final second = int.parse(dateParts[1]);
      
      if (first > 12) {
        // Must be DD/MM/YYYY
        day = first;
        month = second;
      } else if (second > 12) {
        // Must be MM/DD/YYYY
        month = first;
        day = second;
      } else {
        // Assume DD/MM/YYYY (more common internationally)
        day = first;
        month = second;
      }
      
      year = int.parse(dateParts[2]);
      if (year < 100) year += 2000;
      
      // Parse time
      timeStr = timeStr.trim().toUpperCase();
      final isPM = timeStr.contains('PM');
      final isAM = timeStr.contains('AM');
      timeStr = timeStr.replaceAll(RegExp(r'\s*[AP]M'), '');
      
      final timeParts = timeStr.split(':');
      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final secondVal = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
      
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      
      return DateTime(year, month, day, hour, minute, secondVal);
    } catch (e) {
      return null;
    }
  }

  static Message? _createMessage(DateTime timestamp, String sender, String content) {
    // Check for system messages
    for (final pattern in _systemPatterns) {
      if (pattern.hasMatch(content)) {
        return Message(
          id: _uuid.v4(),
          timestamp: timestamp,
          sender: sender,
          content: content,
          type: MessageType.system,
        );
      }
    }
    
    // Check for media messages
    for (final entry in _mediaPatterns.entries) {
      if (entry.key.hasMatch(content)) {
        return Message(
          id: _uuid.v4(),
          timestamp: timestamp,
          sender: sender,
          content: content,
          type: entry.value,
        );
      }
    }
    
    // Regular text message
    final emojis = EmojiUtils.extractEmojis(content);
    final textWithoutEmojis = EmojiUtils.removeEmojis(content);
    final words = textWithoutEmojis
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    
    // Check if it contains a link
    final hasLink = RegExp(r'https?://').hasMatch(content);
    
    return Message(
      id: _uuid.v4(),
      timestamp: timestamp,
      sender: sender,
      content: content,
      type: hasLink ? MessageType.link : MessageType.text,
      emojis: emojis,
      wordCount: words.length,
      characterCount: content.length,
    );
  }

  static void _updateParticipant(
    Map<String, _ParticipantBuilder> map,
    Message message,
  ) {
    final builder = map.putIfAbsent(
      message.sender,
      () => _ParticipantBuilder(message.sender),
    );
    builder.addMessage(message);
  }
}

class _ParticipantBuilder {
  final String name;
  int messageCount = 0;
  int wordCount = 0;
  int emojiCount = 0;
  int mediaCount = 0;
  DateTime? firstMessage;
  DateTime? lastMessage;
  final Map<String, int> emojiUsage = {};

  _ParticipantBuilder(this.name);

  void addMessage(Message message) {
    messageCount++;
    wordCount += message.wordCount;
    emojiCount += message.emojis.length;
    
    if (message.type != MessageType.text && message.type != MessageType.link) {
      mediaCount++;
    }
    
    if (firstMessage == null || message.timestamp.isBefore(firstMessage!)) {
      firstMessage = message.timestamp;
    }
    if (lastMessage == null || message.timestamp.isAfter(lastMessage!)) {
      lastMessage = message.timestamp;
    }
    
    for (final emoji in message.emojis) {
      emojiUsage[emoji] = (emojiUsage[emoji] ?? 0) + 1;
    }
  }

  Participant build() {
    return Participant(
      name: name,
      messageCount: messageCount,
      wordCount: wordCount,
      emojiCount: emojiCount,
      mediaCount: mediaCount,
      firstMessage: firstMessage,
      lastMessage: lastMessage,
      emojiUsage: Map.from(emojiUsage),
    );
  }
}
