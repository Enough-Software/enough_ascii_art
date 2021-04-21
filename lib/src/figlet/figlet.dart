import 'package:enough_ascii_art/src/figlet/renderer.dart';

import 'font.dart';

enum FigletRenderDirection { LeftToRight, TopToBottom }

/// Helper class to render a FIGure
class FIGlet {
  /// Rendes the given [text] in the specified [font].
  ///
  /// Optionally specify the [direction], which defaults to [FigletRenderDirection.LeftToRight]
  static String renderFIGure(String text, Font font,
      {FigletRenderDirection direction = FigletRenderDirection.LeftToRight}) {
    var renderer = Renderer();
    return renderer.render(text, font, direction);
  }
}
