import 'package:intl/intl.dart';

/// Date/Time formatting utilities
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _monthYear = DateFormat('MMM yyyy');
  static final DateFormat _weekday = DateFormat('EEEE');
  static final DateFormat _shortWeekday = DateFormat('EEE');

  static String dayMonth(DateTime date) => _dayMonth.format(date);
  static String dayMonthYear(DateTime date) => _dayMonthYear.format(date);
  static String time(DateTime date) => _time.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String weekday(DateTime date) => _weekday.format(date);
  static String shortWeekday(DateTime date) => _shortWeekday.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }

  static String chatDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    if (diff.inDays < 30) return '${diff.inDays} days';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months';
    final years = diff.inDays / 365;
    return '${years.toStringAsFixed(1)} years';
  }
}

/// Number formatting utilities
class NumberFormatter {
  NumberFormatter._();

  static String compact(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    if (number < 1000000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  }

  static String percentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  static String duration(Duration duration) {
    if (duration.inSeconds < 60) return '${duration.inSeconds}s';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m';
    if (duration.inHours < 24) {
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return hours > 0 ? '${days}d ${hours}h' : '${days}d';
  }
}

/// Emoji detection utilities
class EmojiUtils {
  EmojiUtils._();

  static final RegExp emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F64F}]|'
    r'[\u{1F300}-\u{1F5FF}]|'
    r'[\u{1F680}-\u{1F6FF}]|'
    r'[\u{1F1E0}-\u{1F1FF}]|'
    r'[\u{2600}-\u{26FF}]|'
    r'[\u{2700}-\u{27BF}]|'
    r'[\u{1F900}-\u{1F9FF}]|'
    r'[\u{1FA00}-\u{1FA6F}]|'
    r'[\u{1FA70}-\u{1FAFF}]|'
    r'[\u{231A}-\u{231B}]|'
    r'[\u{23E9}-\u{23F3}]|'
    r'[\u{23F8}-\u{23FA}]|'
    r'[\u{25AA}-\u{25AB}]|'
    r'[\u{25B6}]|'
    r'[\u{25C0}]|'
    r'[\u{25FB}-\u{25FE}]|'
    r'[\u{2614}-\u{2615}]|'
    r'[\u{2648}-\u{2653}]|'
    r'[\u{267F}]|'
    r'[\u{2693}]|'
    r'[\u{26A1}]|'
    r'[\u{26AA}-\u{26AB}]|'
    r'[\u{26BD}-\u{26BE}]|'
    r'[\u{26C4}-\u{26C5}]|'
    r'[\u{26CE}]|'
    r'[\u{26D4}]|'
    r'[\u{26EA}]|'
    r'[\u{26F2}-\u{26F3}]|'
    r'[\u{26F5}]|'
    r'[\u{26FA}]|'
    r'[\u{26FD}]|'
    r'[\u{2702}]|'
    r'[\u{2705}]|'
    r'[\u{2708}-\u{270D}]|'
    r'[\u{270F}]|'
    r'[\u{2712}]|'
    r'[\u{2714}]|'
    r'[\u{2716}]|'
    r'[\u{271D}]|'
    r'[\u{2721}]|'
    r'[\u{2728}]|'
    r'[\u{2733}-\u{2734}]|'
    r'[\u{2744}]|'
    r'[\u{2747}]|'
    r'[\u{274C}]|'
    r'[\u{274E}]|'
    r'[\u{2753}-\u{2755}]|'
    r'[\u{2757}]|'
    r'[\u{2763}-\u{2764}]|'
    r'[\u{2795}-\u{2797}]|'
    r'[\u{27A1}]|'
    r'[\u{27B0}]|'
    r'[\u{27BF}]|'
    r'[\u{2934}-\u{2935}]|'
    r'[\u{2B05}-\u{2B07}]|'
    r'[\u{2B1B}-\u{2B1C}]|'
    r'[\u{2B50}]|'
    r'[\u{2B55}]|'
    r'[\u{3030}]|'
    r'[\u{303D}]|'
    r'[\u{3297}]|'
    r'[\u{3299}]|'
    r'[\u{FE00}-\u{FE0F}]|'
    r'[\u{200D}]',
    unicode: true,
  );

  static List<String> extractEmojis(String text) {
    return emojiRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  static int countEmojis(String text) {
    return emojiRegex.allMatches(text).length;
  }

  static bool hasEmoji(String text) {
    return emojiRegex.hasMatch(text);
  }

  static String removeEmojis(String text) {
    return text.replaceAll(emojiRegex, '').trim();
  }
}

/// Common stop words for word frequency analysis
class StopWords {
  StopWords._();

  static const Set<String> english = {
    'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'i',
    'it', 'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at',
    'this', 'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she',
    'or', 'an', 'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what',
    'so', 'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me',
    'when', 'make', 'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take',
    'people', 'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other',
    'than', 'then', 'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also',
    'back', 'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well', 'way',
    'even', 'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most', 'us',
    'is', 'are', 'was', 'were', 'been', 'being', 'has', 'had', 'does', 'did',
    'am', 'im', "i'm", "don't", "didn't", "can't", "won't", "isn't", "aren't",
    'ok', 'okay', 'yeah', 'yes', 'yep', 'nope', 'ya', 'lol', 'haha',
    'ha', 'oh', 'ah', 'um', 'uh', 'hmm', 'hm', 'hey', 'hi', 'hello',
    'bye', 'thanks', 'thank', 'please', 'sorry', 'sure', 'right',
  };

  static bool isStopWord(String word) {
    return english.contains(word.toLowerCase());
  }
}
