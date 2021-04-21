import 'package:image/image.dart';

/// Converts images to ASCII
class ImageConverter {
  static const String _asciiGrayScaleCharacters = '#@%=+*:-. ';

  /// Converts the image to ASCII text.
  ///
  /// [image] the image to be converted
  /// [maxWidth] the optional maximum width of the image in characters, defaults to 80
  /// [maxHeight] the optional maximum height of the image in characters, defaults to null, so the image is scaled linearily
  /// [charSet] the optional charset from darkest to lightest character, defaults to '#@%=+*:-. '
  /// [invert] allows to invert pixels, so that a dark pixel gets a bright characater and vise versa. This is useful when printing bight text on a dark background (console). Defaults to false.
  /// [fontHeightCompensationFactor] the optional factor between 0 and 1 that is used to adjust the height of the image. Most fonts have a greater height than width, so this factor allows to compensate this. Defaults to 0.6.
  static String convertImage(Image image,
      {int maxWidth = 80,
      int? maxHeight,
      String charset = _asciiGrayScaleCharacters,
      bool invert = false,
      double fontHeightCompensationFactor = 0.6}) {
    var scaleFactor = maxWidth / image.width;
    if (maxHeight != null) {
      var heightFactor = maxHeight / image.height;
      if (heightFactor < scaleFactor) {
        scaleFactor = heightFactor;
      }
    }
    var scaledWidth = (image.width * scaleFactor).round();
    // as fonts are typically much higher than wide, adjust the scaled height to compensate:
    var scaledHeight =
        (image.height * scaleFactor * fontHeightCompensationFactor).round();
    var scaledImage =
        copyResize(image, width: scaledWidth, height: scaledHeight);
    var buffer = StringBuffer();
    for (var y = 0; y < scaledImage.height; y++) {
      for (var x = 0; x < scaledImage.width; x++) {
        var pixel = scaledImage.getPixel(x, y);
        var grayscale =
            (pixel >> 16 & 0xff) | (pixel >> 8 & 0xff) | (pixel & 0xff);
        var index = (grayscale * (charset.length - 1) / 255).floor();
        if (invert) {
          index = (charset.length - 1) - index;
        }
        buffer.write(charset[index]);
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }
}
