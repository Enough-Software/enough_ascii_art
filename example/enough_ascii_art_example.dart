import 'dart:io';
import 'package:enough_ascii_art/enough_ascii_art.dart';
import 'package:image/image.dart' as img;

void main() async {
  var image = img.decodeImage(File('./example/enough.jpg').readAsBytesSync());
  var asciiImage = convertImage(image, maxWidth: 40, invert: true);
  print('');
  print(asciiImage);
  var helloWithUtf8Smileys = 'hello world 😛';
  var helloWithTextSmileys =
      convertEmoticons(helloWithUtf8Smileys, EmoticonStyle.western);
  print('');
  print(helloWithTextSmileys);
  print('');
  print('cosmic:');
  var figure = await renderFigletWithFontName('ENOUGH', 'cosmic');
  print(figure);
  print('');
  print('shadow:');
  figure = await renderFigletWithFontName('ENOUGH', 'shadow');
  print(figure);
  print('');
  print('smslant:');
  figure = await renderFigletWithFontName('ENOUGH', 'smslant');
  print(figure);
  print('');
  print('eftifont:');
  figure = await renderFigletWithFontName('ENOUGH', 'eftifont');
  print(figure);
  print('');
  print('big:');
  figure = await renderFigletWithFontName('ENOUGH', 'big');
  print(figure);
  print('');
  print('isometric1:');
  figure = await renderFigletWithFontName('ENOUGH', 'isometric1');
  print(figure);
  print('');
  print('chunky:');
  figure = await renderFigletWithFontName('ENOUGH', 'chunky');
  print(figure);
  print('');
}
