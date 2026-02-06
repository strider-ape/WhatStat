import '../core/models.dart';
import '../core/utils.dart';

/// Analytics computed from parsed chat data
class ChatAnalytics {
  final ChatData chatData;
  
  // Cached computed values
  late final Map<String, int> _wordFrequency;
  late final Map<String, int> _emojiFrequency;
  late final List<List<int>> _heatmapData;
  late final Map<DateTime, int> _dailyMessages;
  late final Map<String, Duration> _responseTimesByParticipant;

  ChatAnalytics(this.chatData) {
    _computeWordFrequency();
    _computeEmojiFrequency();
    _computeHeatmap();
    _computeDailyMessages();
    _computeResponseTimes();
  }

  // ============ OVERVIEW STATS ============

  int get totalMessages => chatData.totalMessages;
  int get totalWords => chatData.totalWords;
  int get totalEmojis => chatData.totalEmojis;
  int get totalMedia => chatData.totalMedia;
  int get participantCount => chatData.participantCount;
  int get totalDays => chatData.chatDuration.inDays;
  double get avgMessagesPerDay => chatData.averageMessagesPerDay;
  
  double get avgWordsPerMessage {
    if (totalMessages == 0) return 0;
    return totalWords / totalMessages;
  }

  String get mostActiveDay {
    if (_dailyMessages.isEmpty) return 'N/A';
    final sorted = _dailyMessages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return DateFormatter.weekday(sorted.first.key);
  }

  String get mostActiveHour {
    final hourCounts = List.filled(24, 0);
    for (final msg in chatData.messages) {
      hourCounts[msg.timestamp.hour]++;
    }
    int maxHour = 0;
    for (int i = 1; i < 24; i++) {
      if (hourCounts[i] > hourCounts[maxHour]) maxHour = i;
    }
    return '${maxHour.toString().padLeft(2, '0')}:00';
  }

  // ============ TIMELINE DATA ============

  List<MapEntry<DateTime, int>> get dailyMessageCounts {
    final sorted = _dailyMessages.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }

  List<MapEntry<String, int>> get weeklyMessageCounts {
    final weeklyMap = <String, int>{};
    for (final entry in _dailyMessages.entries) {
      final weekStart = entry.key.subtract(Duration(days: entry.key.weekday - 1));
      final key = DateFormatter.dayMonth(weekStart);
      weeklyMap[key] = (weeklyMap[key] ?? 0) + entry.value;
    }
    return weeklyMap.entries.toList();
  }

  List<MapEntry<String, int>> get monthlyMessageCounts {
    final monthlyMap = <String, int>{};
    for (final entry in _dailyMessages.entries) {
      final key = DateFormatter.monthYear(entry.key);
      monthlyMap[key] = (monthlyMap[key] ?? 0) + entry.value;
    }
    return monthlyMap.entries.toList();
  }

  // ============ ACTIVITY HEATMAP ============

  /// 7x24 matrix: [dayOfWeek][hourOfDay] = messageCount
  /// dayOfWeek: 0 = Monday, 6 = Sunday
  List<List<int>> get heatmapData => _heatmapData;

  int get peakHour {
    int maxHour = 0;
    int maxCount = 0;
    for (int h = 0; h < 24; h++) {
      int count = 0;
      for (int d = 0; d < 7; d++) {
        count += _heatmapData[d][h];
      }
      if (count > maxCount) {
        maxCount = count;
        maxHour = h;
      }
    }
    return maxHour;
  }

  int get peakDay {
    int maxDay = 0;
    int maxCount = 0;
    for (int d = 0; d < 7; d++) {
      int count = 0;
      for (int h = 0; h < 24; h++) {
        count += _heatmapData[d][h];
      }
      if (count > maxCount) {
        maxCount = count;
        maxDay = d;
      }
    }
    return maxDay;
  }

  // ============ EMOJI STATS ============

  List<MapEntry<String, int>> get topEmojis {
    final sorted = _emojiFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(50).toList();
  }

  Map<String, List<MapEntry<String, int>>> get topEmojisByParticipant {
    final result = <String, List<MapEntry<String, int>>>{};
    for (final p in chatData.participants) {
      final sorted = p.emojiUsage.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      result[p.name] = sorted.take(10).toList();
    }
    return result;
  }

  // ============ WORD STATS ============

  List<MapEntry<String, int>> get topWords {
    final filtered = _wordFrequency.entries
        .where((e) => !StopWords.isStopWord(e.key) && e.key.length > 2)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return filtered.take(100).toList();
  }

  int get uniqueWords => _wordFrequency.length;

  double get avgWordLength {
    if (_wordFrequency.isEmpty) return 0;
    int totalLength = 0;
    int totalCount = 0;
    for (final entry in _wordFrequency.entries) {
      totalLength += entry.key.length * entry.value;
      totalCount += entry.value;
    }
    return totalLength / totalCount;
  }

  // ============ PARTICIPANT STATS ============

  List<ParticipantAnalytics> get participantStats {
    return chatData.participants.map((p) {
      final percentage = totalMessages > 0 
          ? (p.messageCount / totalMessages) * 100 
          : 0.0;
      
      final avgWords = p.messageCount > 0 
          ? p.wordCount / p.messageCount 
          : 0.0;
      
      return ParticipantAnalytics(
        participant: p,
        messagePercentage: percentage,
        avgWordsPerMessage: avgWords,
        avgResponseTime: _responseTimesByParticipant[p.name] ?? Duration.zero,
        topEmojis: p.emojiUsage.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );
    }).toList();
  }

  // ============ RESPONSE TIME ============

  Duration get avgResponseTime {
    if (_responseTimesByParticipant.isEmpty) return Duration.zero;
    final total = _responseTimesByParticipant.values
        .fold<int>(0, (sum, d) => sum + d.inSeconds);
    return Duration(seconds: total ~/ _responseTimesByParticipant.length);
  }

  Map<String, Duration> get responseTimesByParticipant => _responseTimesByParticipant;

  String get fastestResponder {
    if (_responseTimesByParticipant.isEmpty) return 'N/A';
    final sorted = _responseTimesByParticipant.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.first.key;
  }

  // ============ PRIVATE COMPUTATION METHODS ============

  void _computeWordFrequency() {
    _wordFrequency = {};
    for (final msg in chatData.messages) {
      if (msg.type != MessageType.text && msg.type != MessageType.link) continue;
      
      final text = EmojiUtils.removeEmojis(msg.content).toLowerCase();
      final words = text.split(RegExp(r'[\s\p{P}]+', unicode: true))
          .where((w) => w.isNotEmpty && w.length > 1);
      
      for (final word in words) {
        _wordFrequency[word] = (_wordFrequency[word] ?? 0) + 1;
      }
    }
  }

  void _computeEmojiFrequency() {
    _emojiFrequency = {};
    for (final msg in chatData.messages) {
      for (final emoji in msg.emojis) {
        _emojiFrequency[emoji] = (_emojiFrequency[emoji] ?? 0) + 1;
      }
    }
  }

  void _computeHeatmap() {
    _heatmapData = List.generate(7, (_) => List.filled(24, 0));
    for (final msg in chatData.messages) {
      final day = (msg.timestamp.weekday - 1) % 7; // 0 = Monday
      final hour = msg.timestamp.hour;
      _heatmapData[day][hour]++;
    }
  }

  void _computeDailyMessages() {
    _dailyMessages = {};
    for (final msg in chatData.messages) {
      final date = DateTime(
        msg.timestamp.year,
        msg.timestamp.month,
        msg.timestamp.day,
      );
      _dailyMessages[date] = (_dailyMessages[date] ?? 0) + 1;
    }
  }

  void _computeResponseTimes() {
    _responseTimesByParticipant = {};
    final responseTimes = <String, List<Duration>>{};
    
    for (int i = 1; i < chatData.messages.length; i++) {
      final prev = chatData.messages[i - 1];
      final curr = chatData.messages[i];
      
      // Skip if same sender or system message
      if (prev.sender == curr.sender) continue;
      if (prev.type == MessageType.system || curr.type == MessageType.system) continue;
      
      final diff = curr.timestamp.difference(prev.timestamp);
      
      // Only count reasonable response times (1 second to 24 hours)
      if (diff.inSeconds > 0 && diff.inHours < 24) {
        responseTimes.putIfAbsent(curr.sender, () => []).add(diff);
      }
    }
    
    for (final entry in responseTimes.entries) {
      if (entry.value.isEmpty) continue;
      final total = entry.value.fold<int>(0, (sum, d) => sum + d.inSeconds);
      _responseTimesByParticipant[entry.key] = Duration(
        seconds: total ~/ entry.value.length,
      );
    }
  }

  // ============ INSIGHTS ============

  List<Insight> get insights {
    final result = <Insight>[];
    
    // Longest streak
    final streak = _calculateLongestStreak();
    if (streak > 1) {
      result.add(Insight(
        emoji: '🔥',
        title: 'Longest Streak',
        value: '$streak days',
        description: 'of consecutive chatting',
      ));
    }
    
    // Most chatty day
    if (_dailyMessages.isNotEmpty) {
      final maxEntry = _dailyMessages.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      result.add(Insight(
        emoji: '📅',
        title: 'Busiest Day',
        value: DateFormatter.dayMonthYear(maxEntry.key),
        description: '${maxEntry.value} messages exchanged',
      ));
    }
    
    // Most used emoji
    if (topEmojis.isNotEmpty) {
      result.add(Insight(
        emoji: topEmojis.first.key,
        title: 'Favorite Emoji',
        value: topEmojis.first.key,
        description: 'used ${topEmojis.first.value} times',
      ));
    }
    
    // Night owl / Early bird
    final lateNightCount = List.generate(6, (i) => i).fold<int>(
      0, (sum, h) => sum + _heatmapData.fold(0, (s, d) => s + d[h]),
    );
    final morningCount = List.generate(6, (i) => i + 6).fold<int>(
      0, (sum, h) => sum + _heatmapData.fold(0, (s, d) => s + d[h]),
    );
    
    if (lateNightCount > morningCount * 0.5) {
      result.add(Insight(
        emoji: '🦉',
        title: 'Night Owls',
        value: NumberFormatter.compact(lateNightCount),
        description: 'messages sent between midnight and 6 AM',
      ));
    }
    
    return result;
  }

  int _calculateLongestStreak() {
    if (_dailyMessages.isEmpty) return 0;
    
    final dates = _dailyMessages.keys.toList()..sort();
    int maxStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    
    return maxStreak;
  }
}

/// Analytics for a single participant
class ParticipantAnalytics {
  final Participant participant;
  final double messagePercentage;
  final double avgWordsPerMessage;
  final Duration avgResponseTime;
  final List<MapEntry<String, int>> topEmojis;

  const ParticipantAnalytics({
    required this.participant,
    required this.messagePercentage,
    required this.avgWordsPerMessage,
    required this.avgResponseTime,
    required this.topEmojis,
  });
}

/// A fun insight about the chat
class Insight {
  final String emoji;
  final String title;
  final String value;
  final String description;

  const Insight({
    required this.emoji,
    required this.title,
    required this.value,
    required this.description,
  });
}
