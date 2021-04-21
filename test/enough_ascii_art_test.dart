import 'package:enough_ascii_art/enough_ascii_art.dart';
import 'package:enough_ascii_art/src/unicode_font_converter.dart';
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

  group('Unicode font tests', () {
    test('Convert to double struck', () {
      expect(
          UnicodeFontConverter.encode('hello world', UnicodeFont.doublestruck),
          '𝕙𝕖𝕝𝕝𝕠 𝕨𝕠𝕣𝕝𝕕');
    });
    test('Convert to fraktur', () {
      expect(
          UnicodeFontConverter.encode('hello world', UnicodeFont.frakturBold),
          '𝖍𝖊𝖑𝖑𝖔 𝖜𝖔𝖗𝖑𝖉');
    });
  });
}
