import 'figlet.dart';
import 'font.dart';

enum RenderOptions { none }

/// Renders FIGlet fonts for a given text
class Renderer {
  /// Renders the given text in the specified font.
  ///
  /// [text] the text to render
  /// [font] the FIGlet font to be used for rendering
  /// [maxLineWidth] the optional maximum width for a single line, currently ignored
  /// [horizontalLayouts] the optional rules for horizontal layouting
  /// [verticalLayouts] the options rules for vertical layouting, currently ignored
  String render(
    String text,
    Font font,
    FigletRenderDirection direction, {
    int? maxLineWidth,
    List<HorizontalLayout>? horizontalLayouts,
    List<VerticalLayout>? verticalLayouts,
  }) {
    horizontalLayouts ??= font.horizontalLayouts;
    if (direction == FigletRenderDirection.LeftToRight) {
      return _renderLR(text, font, horizontalLayouts!);
    } else {
      return _renderTB(text, font);
    }
  }

  void _processRune(
    _RenderLine renderLine,
    int rune,
    Font font,
    List<HorizontalLayout>? horizontalLayouts,
  ) {
    final character = font.getCharacter(rune);
    if (character != null) {
      renderLine.addCharacterToRight(character, horizontalLayouts);
      //TODO observe line width and wrap text when reaching maximum width
      //TODO observe text direction
    }
  }

  String _renderLR(
    String text,
    Font font,
    List<HorizontalLayout> horizontalLayouts,
  ) {
    var renderLine = _RenderLine(font);
    final runes = text.runes;
    for (var rune in runes) {
      _processRune(renderLine, rune, font, horizontalLayouts);
    }
    final result = renderLine.render();
    return result;
  }

  String _renderTB(String text, Font font) {
    final runes = text.runes;
    final result = <String>[];

    for (var rune in runes) {
      final renderLine = _RenderLine(font);
      _processRune(renderLine, rune, font, font.horizontalLayouts);
      result.add(renderLine.render());
    }

    return result.join();
  }
}

class _RenderLine {
  static const int _runeSpace = 32; // ' '
  static const int _runeUnderscore = 95; // _
  static const int _runeVerticalBar = 124; // |
  static const int _runeLeftBracket = 91; // [
  static const int _runeRightBracket = 93; // ]
  static const int _runeLeftBrace = 123; // {
  static const int _runeRightBrace = 125; // }
  static const int _runeLeftParenthese = 40; // (
  static const int _runeRightParenthese = 41; // )
  static const int _runeForwardSlash = 47; // /
  static const int _runeBackwardSlash = 92; // \
  static const int _runeSmallerThan = 60; // <
  static const int _runeLargerThan = 62; // >

  // Underscore smushing: An underscore ("_") will be replaced by any of: "|", "/", "\", "[", "]", "{", "}", "(", ")", "<" or ">".
  // Hierarchy smushing: A hierarchy of six classes is used: "|", "/\", "[]", "{}", "()", and "<>".
  static const List<int?> _underscoreOrHierarchyReplacementsRunes = [
    _runeVerticalBar,
    _runeForwardSlash,
    _runeBackwardSlash,
    _runeLeftBracket,
    _runeRightBracket,
    _runeLeftBrace,
    _runeRightBrace,
    _runeLeftParenthese,
    _runeRightParenthese,
    _runeSmallerThan,
    _runeLargerThan
  ];

  final Font _font;
  final List<_RenderCharacter> _characters = <_RenderCharacter>[];
  int _width = 0;

  _RenderLine(this._font);

  int addCharacterToRight(
      Character character, List<HorizontalLayout>? layouts) {
    var isFullWidthLayout = layouts == null ||
        layouts.isEmpty ||
        (layouts.length == 1 && layouts[0] == HorizontalLayout.fullWidth);
    var renderCharacter = _RenderCharacter(character);
    if (isFullWidthLayout) {
      renderCharacter.relativeX = 0;
    } else {
      if (_characters.isNotEmpty) {
        _layoutLeftToRight(_characters.last, renderCharacter, layouts);
      } else {
        _moveToLeft(renderCharacter);
      }
    }
    _characters.add(renderCharacter);
    _width += character.width + renderCharacter.relativeX;
    return _width;
  }

  void _moveToLeft(_RenderCharacter character) {
    var lines = character.character.lines;
    var padding = character.character.width;
    for (var row = 0; row < lines.length; row++) {
      var line = lines[row];
      var pos = findNonSpaceRuneFromLeft(line.runes);
      if (pos.steps < padding) {
        padding = pos.steps;
      }
    }
    character.relativeX = -padding;
  }

  void _layoutLeftToRight(_RenderCharacter left, _RenderCharacter right,
      List<HorizontalLayout>? layouts) {
    var originalRightCharacter =
        right.character; // used to restore in case smushing needs to be aborted
    var hardblank = _font.hardblank;
    var rightLines = right.character.lines;
    var leftLines = left.character.lines;
    var linesCount = rightLines.length;
    // first layout path: only fit lines together to determine the closed distance,
    // then apply smushing in a second step:
    var xAdjust = left.character.width + right.character.width;
    for (var row = 0; row < linesCount; row++) {
      var leftPos = findNonSpaceRuneFromRight(leftLines[row].runes);
      var rightPos = findNonSpaceRuneFromLeft(rightLines[row].runes);
      var maxExtend = leftPos.steps + rightPos.steps;
      if (maxExtend < xAdjust) {
        xAdjust = maxExtend;
      }
    }
    // second layout path: anything wider than xAdjust can be ignored:
    var isLayoutRuleApplied = false;
    for (var row = 0; row < linesCount; row++) {
      var leftPos = findNonSpaceRuneFromRight(leftLines[row].runes);
      var rightPos = findNonSpaceRuneFromLeft(rightLines[row].runes);
      var maxExtend = leftPos.steps + rightPos.steps;
      if (maxExtend > xAdjust) {
        continue;
      }
      var isLayoutRuleAppliedForLine = false;
      var leftRune = leftPos.rune;
      var rightRune = rightPos.rune;
      for (var layout in layouts!) {
        switch (layout) {
          // Moves FIGcharacters closer together until they touch.
          // Typographers use the term "kerning" for this phenomenon when applied to the horizontal axis.
          case HorizontalLayout.fittingOnly:
            // nothing else to do
            break;
          // Two sub-characters are smushed into a single sub-character if they are the same. This rule does not smush hardblanks.
          case HorizontalLayout.equalCharacterSmushing:
            if (leftRune == rightRune && leftRune != hardblank) {
              isLayoutRuleAppliedForLine = true;
            }
            break;
          // An underscore ("_") will be replaced by any of: "|", "/", "\", "[", "]", "{", "}", "(", ")", "<" or ">".
          case HorizontalLayout.underscoreSmushing:
            if (leftRune == _runeUnderscore &&
                _underscoreOrHierarchyReplacementsRunes.contains(rightRune)) {
              isLayoutRuleAppliedForLine = true;
            }
            break;
          // A hierarchy of six classes is used: "|", "/\", "[]", "{}", "()", and "<>".
          // When two smushing sub-characters are from different classes, the one from the latter class will be used.
          case HorizontalLayout.hierarchySmushing:
            var leftIndex =
                _underscoreOrHierarchyReplacementsRunes.indexOf(leftRune);
            if (leftIndex != -1) {
              var rightIndex =
                  _underscoreOrHierarchyReplacementsRunes.indexOf(rightRune);
              if ((rightIndex > leftIndex) &&
                  (leftIndex & 1 == 0 || rightIndex > leftIndex + 1)) {
                isLayoutRuleAppliedForLine = true;
              } else if ((rightIndex < leftIndex) &&
                  (leftIndex & 1 == 1 || rightIndex < leftIndex - 1)) {
                isLayoutRuleAppliedForLine = true;
                replace(right, row, rightPos, String.fromCharCode(leftRune!));
              }
            }
            break;
          // Smushes opposing brackets ("[]" or "]["), braces ("{}" or "}{") and parentheses ("()" or ")(") together,
          // replacing any such pair with a vertical bar ("|").
          case HorizontalLayout.oppositePairSmushing:
            if (leftRune != null && rightRune != null) {
              if ((leftRune == _runeLeftBracket &&
                      rightRune == _runeRightBracket) || // []
                  (leftRune == _runeRightBracket &&
                      rightRune == _runeLeftBracket) || // ][
                  (leftRune == _runeLeftBrace &&
                      rightRune == _runeRightBrace) || // {}
                  (leftRune == _runeRightBrace &&
                      rightRune == _runeLeftBrace) || // }{
                  (leftRune == _runeLeftParenthese &&
                      rightRune == _runeRightParenthese) || // ()
                  (leftRune == _runeRightParenthese &&
                      rightRune == _runeLeftParenthese)) // )(
              {
                // replace right character:
                isLayoutRuleAppliedForLine = true;
                replace(right, row, rightPos, '|');
              }
            }
            break;
          // Smushes "/\" into "|", "\/" into "Y", and "><" into "X".
          // Note that "<>" is not smushed in any way by this rule. T
          // he name "BIG X" is historical; originally all three pairs were smushed into "X".
          case HorizontalLayout.bigXSmushing:
            if (leftRune == _runeForwardSlash &&
                rightRune == _runeBackwardSlash) {
              isLayoutRuleAppliedForLine = true;
              replace(right, row, rightPos, '|');
            } else if (leftRune == _runeBackwardSlash &&
                rightRune == _runeForwardSlash) {
              isLayoutRuleAppliedForLine = true;
              replace(right, row, rightPos, 'Y');
            } else if (leftRune == _runeLargerThan &&
                rightRune == _runeSmallerThan) {
              isLayoutRuleAppliedForLine = true;
              replace(right, row, rightPos, 'X');
            }
            break;
          // Smushes two hardblanks together, replacing them with a single hardblank.
          case HorizontalLayout.hardblankSmushing:
            if (leftRune == rightRune && rightRune == hardblank) {
              isLayoutRuleAppliedForLine = true;
            }
            break;

          // Universal smushing simply overrides the sub-character from the earlier FIGcharacter with the sub-character
          // from the later FIGcharacter.
          // This produces an "overlapping" effect with some FIGfonts, wherin the latter FIGcharacter may appear to be "in front".
          case HorizontalLayout.universalSmushing:
            isLayoutRuleAppliedForLine = true;
            break;

          default:
            print('Unsupported horizontal layout $layout');
        }
        if (isLayoutRuleAppliedForLine) {
          // var match = String.fromCharCodes([leftRune, rightRune]);
          // print('matching rule: $layout for $match');
          isLayoutRuleApplied = true;
          break; // do not check any more layout rules
        }
      } // for each layout
      if (!isLayoutRuleAppliedForLine) {
        // var match = String.fromCharCodes([leftRune, rightRune]);
        // print('no matching rule for $match, aborting');
        isLayoutRuleApplied = false;
        right.character = originalRightCharacter;
        break;
      }
    }
    if (isLayoutRuleApplied) {
      xAdjust++;
    }
    right.relativeX = -xAdjust;
  }

  void replace(_RenderCharacter renderCharacter, int row, _RunePos replacePos,
      String replacement) {
    var copy = renderCharacter.character.copy();
    var copyLine = copy.lines[row];
    var pos = replacePos.pos;
    if (pos == 0) {
      copyLine = replacement + copyLine.substring(1);
    } else if (pos == copyLine.length - 1) {
      copyLine = copyLine.substring(0, pos) + replacement;
    } else {
      copyLine = copyLine.substring(0, pos) +
          replacement +
          copyLine.substring(pos! + 1);
    }
    copy.lines[row] = copyLine;
    //print('replaced ${renderCharacter.character.lines[row]} with $copyLine');
    renderCharacter.character = copy;
  }

  _RunePos findNonSpaceRuneFromRight(Runes runes) {
    var steps = 0;
    for (var charIndex = runes.length; --charIndex >= 0;) {
      var rune = runes.elementAt(charIndex);
      if (rune != _runeSpace) {
        return _RunePos(rune, charIndex, steps);
      }
      steps++;
    }
    return _RunePos(null, null, steps);
  }

  _RunePos findNonSpaceRuneFromLeft(Runes runes) {
    var steps = 0;
    for (var charIndex = 0; charIndex < runes.length; charIndex++) {
      var rune = runes.elementAt(charIndex);
      if (rune != _runeSpace) {
        return _RunePos(rune, charIndex, steps);
      }
      steps++;
    }
    return _RunePos(null, null, steps);
  }

  String render() {
    final runeHardblank = _font.hardblank;
    final buffer = StringBuffer();
    for (var row = 0; row < _font.height; row++) {
      final lineOfRunes = List.filled(_width, 32);
      var charIndex = 0;
      for (var char in _characters) {
        charIndex += char.relativeX;
        var charLineRunes = char.character.lines[row].runes;
        for (var printIndex = 0;
            printIndex < charLineRunes.length;
            printIndex++) {
          var rune = charLineRunes.elementAt(printIndex);
          if (rune == runeHardblank) {
            rune = _runeSpace;
          }
          if (charIndex >= 0 && (rune != _runeSpace)) {
            lineOfRunes[charIndex] = rune;
          }
          charIndex++;
        }
      }
      var text = String.fromCharCodes(lineOfRunes);
      buffer.write(text);
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

class _RenderCharacter {
  Character character;
  late int relativeX;
  _RenderCharacter(this.character);
}

class _RunePos {
  final int? rune;
  final int? pos;
  final int steps;
  _RunePos(this.rune, this.pos, this.steps);
}
