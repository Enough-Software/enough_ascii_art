/// The style of the emoticons.
/// Currently only the western emoticon style is supported.
enum EmoticonStyle { western }

/// Converts common UTF-8 smileys to their ASCII representation
class EmoticonConverter {
  static const Map<String, String> _westernStyleEmoticons = <String, String>{
    '😀': ':-)',
    '😊': ':-)',
    '😁': ':-D',
    '😄': ':-D',
    '😃': ':-D',
    '😉': ';-)',
    '😂': ':\')',
    '😅': ':\')',
    '🤣': ':D',
    '😋': ':-P',
    '😛': ':-P',
    '😮': ':-O',
    '😲': '8-0',
    '☹': ':-(',
    '🙁': ':-(',
    '😒': ':-(',
    '😜': ';-P',
    '😆': 'X-D',
    '😎': '8-)',
    '😍': '<3',
    '😘': '<3',
    '🥰': '<3',
    '😐': ':-|',
    '😴': '(-.-)Zzz…',
    '👋': 'o/',
    '💔': '</3',
    '💗': '<3',
    '❤': '<3',
    '💋': '<3',
    '😇': '0:)',
    '😈': '3:)',
    '😖': '%)',
    '😠': ':-@',
    '😡': ':-.',
    '😢': ':\'(',
    '😥': ':\'(',
    '😤': '^5',
    '😫': '|-O',
    '😰': ':###..',
    '😱': 'D-\':',
    '😳': ':\$',
    '😵': '#-)',
    '😶': ':#',
    '😼': ':-J',
    '😽': ':*',
    '😗': ':-*',
    '🙄': '8-/',
    '👍': '+1',
    '✅': '+1',
    '✔': '+1'
  };

  /// Replaces all common smileys with their ASCII representation
  ///
  /// [text] the text that may contain smileys
  /// [style] the optional emoticon style
  static String convertEmoticons(String text,
      [EmoticonStyle style = EmoticonStyle.western]) {
    if (text.isEmpty) {
      return text;
    }
    switch (style) {
      case EmoticonStyle.western:
      default:
        return _convert(text, _westernStyleEmoticons);
    }
  }

  static String _convert(String text, Map<String, String> emoticons) {
    for (var key in emoticons.keys) {
      text = text.replaceAll(key, emoticons[key]!);
    }
    return text;
  }
}
