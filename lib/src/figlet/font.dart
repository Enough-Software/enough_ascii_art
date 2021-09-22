import 'dart:convert';
import 'dart:typed_data';

import 'package:enough_ascii_art/enough_ascii_art.dart';

/// The direction for rendering a font
enum PrintDirection { leftToRight, rightToLeft }

/// Smushing brings FIGlet character closer together.
///
/// Smushing can be done both horizontally as well as vertically.
enum HorizontalLayout {
  /// No smushing is applied
  fullWidth,

  /// Moves FIGcharacters closer together until they touch. Typographers use the term "kerning" for this phenomenon when applied to the horizontal axis, but fitting also includes this as a vertical behavior, for which there is apparently no established typographical term.
  fittingOnly,

  /// Two sub-characters are smushed into a single sub-character if they are the same. This rule does not smush hardblanks. (See [hardblank] below.)
  equalCharacterSmushing,

  /// An underscore ("_") will be replaced by any of: "|", "/", "\", "[", "]", "{", "}", "(", ")", "<" or ">".
  underscoreSmushing,

  /// A hierarchy of six classes is used: "|", "/\", "[]", "{}", "()", and "<>". When two smushing sub-characters are from different classes, the one from the latter class will be used.
  hierarchySmushing,

  /// Smushes opposing brackets ("[]" or "]["), braces ("{}" or "}{") and parentheses ("()" or ")(") together, replacing any such pair with a vertical bar ("|").
  oppositePairSmushing,

  /// Smushes "/\" into "|", "\/" into "Y", and "><" into "X". Note that "<>" is not smushed in any way by this rule. The name "BIG X" is historical; originally all three pairs were smushed into "X".
  bigXSmushing,

  /// Smushes two hardblanks together, replacing them with a single hardblank.
  hardblankSmushing,

  /// Universal smushing simply overrides the sub-character from the earlier FIGcharacter with the sub-character from the later FIGcharacter. This produces an "overlapping" effect with some FIGfonts, wherin the latter FIGcharacter may appear to be "in front".
  universalSmushing
}

/// Smushing brings FIGlet character closer together.
///
/// Smushing can be done both horizontally as well as vertically.
enum VerticalLayout {
  /// No smushing is applied
  fullHeight,

  /// Moves FIGcharacters closer together until they touch. Typographers use the term "kerning" for this phenomenon when applied to the horizontal axis, but fitting also includes this as a vertical behavior, for which there is apparently no established typographical term.
  fittingOnly,

  /// Two sub-characters are smushed into a single sub-character if they are the same. This rule does not smush hardblanks. (See [hardblank] below.)
  equalCharacterSmushing,

  /// An underscore ("_") will be replaced by any of: "|", "/", "\", "[", "]", "{", "}", "(", ")", "<" or ">".
  underscoreSmushing,

  /// A hierarchy of six classes is used: "|", "/\", "[]", "{}", "()", and "<>". When two smushing sub-characters are from different classes, the one from the latter class will be used.
  hierarchySmushing,

  /// Smushes stacked pairs of "-" and "_", replacing them with a single "=" sub-character. It does not matter which is found above the other. Note that vertical smushing rule 1 will smush IDENTICAL pairs of horizontal lines, while this rule smushes horizontal lines consisting of DIFFERENT sub-characters.
  horizontalLineSmushing,

  /// This one rule is different from all others, in that it "supersmushes" vertical lines consisting of several vertical bars ("|"). This creates the illusion that FIGcharacters have slid vertically against each other. Supersmushing continues until any sub-characters other than "|" would have to be smushed. Supersmushing can produce impressive results, but it is seldom possible, since other sub-characters would usually have to be considered for smushing as soon as any such stacked vertical lines are encountered.
  verticalLineSuperSmushing,

  /// Universal smushing simply overrides the sub-character from the earlier FIGcharacter with the sub-character from the later FIGcharacter. This produces an "overlapping" effect with some FIGfonts, wherin the latter FIGcharacter may appear to be "in front".
  universalSmushing
}

/// A FIGfont is a file which represents the graphical arrangement of characters representing larger characters.
///
/// Since a FIGfont file is a text file, it can be created with any text editing program on any platform. The filename of a FIGfont file must end with ".flf", which stands for "FIGLettering Font".
class Font {
  int? hardblank;
  late int height;
  int? baseLine;
  int? maxCharacterLength;
  PrintDirection? printDirection;
  List<HorizontalLayout>? horizontalLayouts;
  bool get isFullWidthLayout =>
      horizontalLayouts == null ||
      (horizontalLayouts!.length == 1 &&
          horizontalLayouts!.first == HorizontalLayout.fullWidth);

  Character? _zeroCharacter;
  final _charactersByRuneCode = <int, Character>{};

  void addCharacter(
      int runeCode, int characterWidth, List<String> characterLines) {
    var character = Character(characterWidth, characterLines);
    _charactersByRuneCode[runeCode] = character;
    if (runeCode == 0) {
      _zeroCharacter = character;
    }
  }

  Character? getCharacter(int rune) {
    var character = _charactersByRuneCode[rune];
    return character ?? _zeroCharacter;
  }

  static Font text(String text) {
    return Parser().parseFontDefinitionByText(text);
  }

  static Font memory(Uint8List bytes, {Encoding codec = utf8}) {
    return text(codec.decode(bytes));
  }
}

/// Because FIGfonts describe large characters which consist of smaller characters, confusion can result when descussing one or the other. Therefore, the terms "FIGcharacter" and "sub-character" are used, respectively.
class Character {
  int width;
  List<String> lines;
  Character(this.width, this.lines);

  Character copy() {
    var copyLines = <String>[];
    copyLines.addAll(lines);
    return Character(width, copyLines);
  }
}
