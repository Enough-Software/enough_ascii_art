An ASCII art library for Dart developers.

Available under the commercial friendly 
[MPL Mozilla Public License 2.0](https://www.mozilla.org/en-US/MPL/).

## Usage

Currently you can convert images and emoticons to a plain text representation:

```dart
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

```
## Installation
Add this dependency your pubspec.yaml file:

```
dependencies:
  enough_ascii_art: ^0.8.0
```
The latest version or `enough_ascii_art` is [![enough_ascii_art version](https://img.shields.io/pub/v/enough_ascii_art.svg)](https://pub.dartlang.org/packages/enough_ascii_art).


## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Enough-Software/enough_ascii_art/issues

## Run Example
After checking out this project, you can run the example from the root with this command:
```bash
dart ./example/enough_ascii_art_example.dart
```

## Contribute
Any contributions are welcome!

Next planned feature is support for [FIGlet](https://en.wikipedia.org/wiki/FIGlet) banner generation.
