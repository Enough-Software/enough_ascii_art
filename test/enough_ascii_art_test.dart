import 'package:enough_ascii_art/enough_ascii_art.dart';
import 'package:test/test.dart';

void main() {
  group('Emoticon tests', () {
    test('Convert test', () {
      expect(convertEmoticons('😛'), ':-P');
      expect(convertEmoticons('🙁'), ':-(');
      expect(convertEmoticons('😁'), ':-D');
      expect(convertEmoticons('😀'), ':-)');
    });
    test('Convert test with western style', () {
      expect(convertEmoticons('😛', EmoticonStyle.western), ':-P');
      expect(convertEmoticons('🙁', EmoticonStyle.western), ':-(');
      expect(convertEmoticons('😁', EmoticonStyle.western), ':-D');
      expect(convertEmoticons('😀', EmoticonStyle.western), ':-)');
    });
  });
}
