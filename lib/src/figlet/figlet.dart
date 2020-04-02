import 'dart:io';
import 'package:resource/resource.dart' show Resource;
import 'package:enough_ascii_art/src/figlet/parser.dart';
import 'package:enough_ascii_art/src/figlet/renderer.dart';

import 'font.dart';

/// Helper class to render a FIGure
class FIGlet {
  static Future<String> renderFIGureForFontName(
      String text, String fontName) async {
    fontName ??= 'cosmic';
    List<String> fontDefinition;
    try {
      var resource = Resource('package:/lib/src/figlet/fonts/$fontName.flf');
      var text = await resource.readAsString();
      fontDefinition = text.split('\r\n');
      if (fontDefinition.length == 1) {
        fontDefinition = text.split('\n');
      }
    } catch (e) {
      //print(e);
      fontDefinition =
          await File('./lib/src/figlet/fonts/$fontName.flf').readAsLines();
    }

    var parser = Parser();
    var font = parser.parseFontDefinition(fontDefinition);
    return renderFIGure(text, font);
  }

  static String renderFIGure(String text, Font font) {
    var renderer = Renderer();
    return renderer.render(text, font);
  }
}
