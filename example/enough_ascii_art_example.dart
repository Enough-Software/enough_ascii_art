import 'dart:io';
import 'package:enough_ascii_art/enough_ascii_art.dart' as art;
import 'package:image/image.dart' as img;

void main() async {
  final bytes = await File('./example/enough.jpg').readAsBytes();
  final image = img.decodeImage(bytes)!;
  var asciiImage = art.convertImage(image, maxWidth: 40, invert: true);
  print('');
  print(asciiImage);

  var helloWithUtf8Smileys = 'hello world 😛';
  var helloWithTextSmileys =
      art.convertEmoticons(helloWithUtf8Smileys, art.EmoticonStyle.western);
  print('');
  print(helloWithTextSmileys);
  print('');

  print('cosmic:');
  var fontText = await File('./example/cosmic.flf').readAsString();
  var figure = art.renderFiglet('ENOUGH', art.Font.text(fontText));
  print(figure);
  print('');

  var unicode = art.renderUnicode('hello world', art.UnicodeFont.doublestruck);
  print('double struck:');
  print(unicode);
}
