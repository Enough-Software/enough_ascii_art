import 'package:enough_ascii_art/src/figlet/renderer.dart';

import 'font.dart';

enum FigletRenderDirection { leftToRight, topToBottom }

/// Helper class to render a FIGure
class FIGlet {
  /// Renders the given [text] in the specified [font].
  ///
  /// Optionally specify the [direction], which defaults to [FigletRenderDirection.leftToRight]
  static String renderFIGure(String text, Font font,
      {FigletRenderDirection direction = FigletRenderDirection.leftToRight}) {
    var renderer = Renderer();
    return renderer.render(text, font, direction);
  }
}
