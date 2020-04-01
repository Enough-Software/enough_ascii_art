import 'dart:io';
import 'package:enough_ascii_art/enough_ascii_art.dart';
import 'package:image/image.dart' as img;

void main() {
  var image = img.decodeImage(File('./example/enough.jpg').readAsBytesSync());
  var asciiImage = convertImage(image, maxWidth: 40, invert: true);
  print(asciiImage);
  var helloWithUtf8Smileys = 'hello world 😛';
  var helloWithTextSmileys =
      convertEmoticons(helloWithUtf8Smileys, EmoticonStyle.western);
  print(helloWithTextSmileys);
}
