import 'font.dart';

enum _ParsePhase { ascii, umlauts, utf8 }

class Parser {
  static const String _magic = 'flf2a';
  static const int horizontalFullLayoutFullWidth = 0;
  static const int horizontalEqualCharacterSmushing = 1;
  static const int horizontalUnderscoreSmushing = 2;
  static const int horizontalHierarchySmushing = 4;
  static const int horizontalOppositePairSmushing = 8;
  static const int horizontalBigXSmushing = 16;
  static const int horizontalHardblankSmushing = 32;
  static const int horizontalFullLayoutFittingOnly = 64;
  static const int horizontalFullLayoutUniversalSmushing = 128;

  static const int horizontalOldLayoutFullWidth = -1;
  static const int horizontalOldLayoutFittingOnly = 0;

  Font parseFontDefinitionByText(String definition) {
    var lines = definition.split('\r\n');
    if (lines.length == 1) {
      lines = definition.split('\n');
    }
    return parseFontDefinition(lines);
  }

  Font parseFontDefinition(List<String> lines) {
    var firstLine = lines.first;
    if (!firstLine.startsWith(_magic)) {
      throw FormatException(
          'Invalid font start: [$firstLine] - expecting magic string [flf2a] at the beginning.');
    }
    var baseDefinitionElements = firstLine.substring(_magic.length).split(' ');
    if (baseDefinitionElements.length < 6) {
      throw FormatException(
          'Invalid font definition: [$firstLine] - not enough font definition elements at the beginning.');
    }
    var hardblank = baseDefinitionElements[0].runes.first;
    var height = int.tryParse(baseDefinitionElements[1]);
    if (height == null || height < 1) {
      throw FormatException(
          'Invalid font definition: [$firstLine] - invalid font height [${baseDefinitionElements[1]}].');
    }
    var baseLine = int.tryParse(baseDefinitionElements[2]);
    var maxCharacterLength = int.tryParse(baseDefinitionElements[3]);
    var oldLayoutInt = int.tryParse(baseDefinitionElements[4]);
    var numberOfCommentLines = int.tryParse(baseDefinitionElements[5]) ?? 0;
    var textDirectionInt = 0;
    int? fullLayoutInt;
    if (baseDefinitionElements.length > 7) {
      textDirectionInt = int.tryParse(baseDefinitionElements[6]) ?? 0;
      fullLayoutInt = int.tryParse(baseDefinitionElements[7]);
    }
    var font = Font()
      ..hardblank = hardblank
      ..height = height
      ..baseLine = baseLine
      ..maxCharacterLength = maxCharacterLength
      ..printDirection = (textDirectionInt == 0)
          ? PrintDirection.leftToRight
          : PrintDirection.rightToLeft
      ..horizontalLayouts = _getHorizontalLayouts(oldLayoutInt, fullLayoutInt);
    /*
          Characters 0-31 are control characters.
      
          Characters 32-126 appear in order:
      
          32 (blank/space) 64 @             96  `
          33 !             65 A             97  a
          34 "             66 B             98  b
          35 #             67 C             99  c
          36 $             68 D             100 d
          37 %             69 E             101 e
          38 &             70 F             102 f
          39 '             71 G             103 g
          40 (             72 H             104 h
          41 )             73 I             105 i
          42 *             74 J             106 j
          43 +             75 K             107 k
          44 ,             76 L             108 l
          45 -             77 M             109 m
          46 .             78 N             110 n
          47 /             79 O             111 o
          48 0             80 P             112 p
          49 1             81 Q             113 q
          50 2             82 R             114 r
          51 3             83 S             115 s
          52 4             84 T             116 t
          53 5             85 U             117 u
          54 6             86 V             118 v
          55 7             87 W             119 w
          56 8             88 X             120 x
          57 9             89 Y             121 y
          58 :             90 Z             122 z
          59 ;             91 [             123 {
          60 <             92 \             124 |
          61 =             93 ]             125 }
          62 >             94 ^             126 ~
          63 ?             95 _
      
          Then codes:
      
          196 Ä
          214 Ö
          220 Ü
          228 ä
          246 ö
          252 ü
          223 ß
      
          If some of these characters are not desired, empty characters may be used, having endmarks flush with the margin.
      
          After the required characters come "code tagged characters" in range -2147483648 to +2147483647, excluding -1. The assumed mapping is to ASCII/Latin-1/Unicode.
      
          A zero character is treated as the character to be used whenever a required character is missing. If no zero character is available, nothing will be printed.
          */
    var lineIndex = 1 + numberOfCommentLines;
    var runeCode = 32;
    var parsePhase = _ParsePhase.ascii;
    final umlauts = [196, 214, 220, 228, 246, 252, 223];
    var germanUmlautIndex = 0;
    while (lineIndex < lines.length) {
      if (parsePhase == _ParsePhase.utf8) {
        // read code unit in first line of character definition:
        var codeUnitLine = lines[lineIndex];
        lineIndex++;
        final spaceIndex = codeUnitLine.indexOf(' ');
        if (spaceIndex != -1) {
          codeUnitLine = codeUnitLine.substring(0, spaceIndex);
        }
        if (codeUnitLine.isEmpty) continue;
        final intValue = int.tryParse(codeUnitLine);
        if (intValue == null) {
          throw FormatException(
              'Invalid font definition at line [$lineIndex]: [$codeUnitLine] contains invalid code unit at beginning.');
        }
        runeCode = intValue;
      }
      var firstCharacterLine = lines[lineIndex];
      var characterWidth = firstCharacterLine.length - 1;
      var characterLines = [firstCharacterLine.substring(0, characterWidth)];
      var characterLineIndex = 1;
      while (characterLineIndex < height) {
        characterLines.add(
            lines[lineIndex + characterLineIndex].substring(0, characterWidth));
        characterLineIndex++;
      }
      font.addCharacter(runeCode, characterWidth, characterLines);
      lineIndex += height;
      switch (parsePhase) {
        case _ParsePhase.ascii:
          runeCode++;
          if (runeCode == 127) {
            parsePhase = _ParsePhase.umlauts;
            runeCode = umlauts[germanUmlautIndex];
          }
          break;
        case _ParsePhase.umlauts:
          germanUmlautIndex++;
          if (germanUmlautIndex == umlauts.length) {
            parsePhase = _ParsePhase.utf8;
          } else {
            runeCode = umlauts[germanUmlautIndex];
          }
          break;
        case _ParsePhase.utf8:
          // read rune code at first line of each character
          break;
      }
    }
    return font;
  }

  List<HorizontalLayout> _getHorizontalLayouts(
      int? oldLayout, int? fullLayout) {
    var layouts = <HorizontalLayout>[];
    var compatibleLayout = fullLayout ?? oldLayout!;
    if (compatibleLayout & horizontalEqualCharacterSmushing ==
        horizontalEqualCharacterSmushing) {
      layouts.add(HorizontalLayout.equalCharacterSmushing);
    }
    if (compatibleLayout & horizontalUnderscoreSmushing ==
        horizontalUnderscoreSmushing) {
      layouts.add(HorizontalLayout.underscoreSmushing);
    }
    if (compatibleLayout & horizontalHierarchySmushing ==
        horizontalHierarchySmushing) {
      layouts.add(HorizontalLayout.hierarchySmushing);
    }
    if (compatibleLayout & horizontalOppositePairSmushing ==
        horizontalOppositePairSmushing) {
      layouts.add(HorizontalLayout.oppositePairSmushing);
    }
    if (compatibleLayout & horizontalBigXSmushing == horizontalBigXSmushing) {
      layouts.add(HorizontalLayout.bigXSmushing);
    }
    if (compatibleLayout & horizontalHardblankSmushing ==
        horizontalHardblankSmushing) {
      layouts.add(HorizontalLayout.hardblankSmushing);
    }
    if (fullLayout != null) {
      if (fullLayout & horizontalFullLayoutUniversalSmushing ==
          horizontalFullLayoutUniversalSmushing) {
        layouts.add(HorizontalLayout.universalSmushing);
      } else if (fullLayout & horizontalFullLayoutFittingOnly ==
          horizontalFullLayoutFittingOnly) {
        layouts.add(HorizontalLayout.fittingOnly);
      }
      if (layouts.isEmpty) {
        layouts.add(HorizontalLayout.fullWidth);
      }
    } else {
      if (oldLayout == -1) {
        layouts.clear();
        layouts.add(HorizontalLayout.fullWidth);
      } else if (layouts.isEmpty) {
        layouts.add(HorizontalLayout.fittingOnly);
      }
    }
    //print('layouts from full $fullLayout / old $oldLayout: $layouts');
    return layouts;
  }
}
