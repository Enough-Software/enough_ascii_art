/// Have fun with ASCII text-based art.
///
/// Brought to you by 𝔼𝕟𝕠𝕦𝕘𝕙 𝕊𝕠𝕗𝕥𝕨𝕒𝕣𝕖
library enough_ascii_art;

import 'package:enough_ascii_art/src/figlet/figlet.dart';
import 'package:enough_ascii_art/src/figlet/font.dart';
import 'package:enough_ascii_art/src/unicode_font_converter.dart';
import 'package:image/image.dart';
import 'src/figlet/figlet.dart';
import 'src/image_converter.dart';
import 'src/emoticon_converter.dart';

export 'src/image_converter.dart';
export 'src/emoticon_converter.dart';
export 'src/unicode_font_converter.dart';
export 'src/figlet/figlet.dart';
export 'src/figlet/font.dart';
export 'src/figlet/parser.dart';
export 'src/figlet/renderer.dart';

const String _asciiGrayScaleCharacters = '#@%=+*:-. ';

/// Converts the image to ASCII text.
///
/// [image] the image to be converted
/// [maxWidth] the optional maximum width of the image in characters, defaults to 80
/// [maxHeight] the optional maximum height of th eimage in characters, defaults to null, so the image is caled linearily
/// [charSet] the optional charset from darkest to lightest character, defaults to '#@%=+*:-. '
/// [invert] allows to invert pixels, so that a dark pixel gets a bright characater and vise versa. This is useful when printing bight text on a dark background (console). Defaults to false.
/// [fontHeightCompensationFactor] the optional factor between 0 and 1 that is used to adjust the height of the image. Most fonts have a greater height than width, so this factor allows to compensate this. Defaults to 0.6.
String convertImage(Image image,
    {int maxWidth = 80,
    int? maxHeight,
    String charset = _asciiGrayScaleCharacters,
    bool invert = false,
    double fontHeightCompensationFactor = 0.6}) {
  return ImageConverter.convertImage(image,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      charset: charset,
      invert: invert,
      fontHeightCompensationFactor: fontHeightCompensationFactor);
}

/// Replaces all common smileys with their ASCII representation
///
/// [text] the text that may contain smileys
/// [style] the optional emoticon style
String convertEmoticons(String text,
    [EmoticonStyle style = EmoticonStyle.western]) {
  return EmoticonConverter.convertEmoticons(text, style);
}

/// Rendes the given [text] in the specified [font].
///
/// Optionally specify the [direction], which defaults to [FigletRenderDirection.LeftToRight]
String renderFiglet(String text, Font font,
    {FigletRenderDirection direction = FigletRenderDirection.LeftToRight}) {
  return FIGlet.renderFIGure(text, font, direction: direction);
}

/// Renders the given [text] in the specified [font].
String renderUnicode(String text, UnicodeFont font) {
  return UnicodeFontConverter.encode(text, font);
}
