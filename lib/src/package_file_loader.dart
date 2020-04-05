import 'dart:io';
import 'dart:isolate';

class PackageFileLoader {
  static final Map<String, String> _libraryPaths = <String, String>{};

  static Future<String> resolveLibraryPath(
      String libraryName, String relativePath) async {
    var libraryPath = _libraryPaths[libraryName];
    if (libraryPath == null && _libraryPaths.isEmpty) {
      var packageUri = await Isolate.packageConfig;
      if (packageUri != null) {
        var packageLines = await File(packageUri.toFilePath()).readAsLines();
        for (var line in packageLines) {
          var splitPos = line.indexOf(':');
          if (splitPos == -1) {
            continue;
          }
          var name = line.substring(0, splitPos);
          var path = line.substring(splitPos + 1);
          if (path.startsWith('file://')) {
            path = path.substring('file://'.length);
          }
          if (path.indexOf(':') == 2) {
            // e.g. '/C:/[...]' or '/D:/[...]'
            path = path.substring(1);
          }
          _libraryPaths[name] = path;
        }
        libraryPath = _libraryPaths[libraryName];
      }
    }
    if (libraryPath != null) {
      if (libraryPath.endsWith('lib/')) {
        if (relativePath.startsWith('lib/')) {
          relativePath = relativePath.substring('lib/'.length);
        } else if (relativePath.startsWith('./lib/')) {
          relativePath = relativePath.substring('./lib/'.length);
        } else if (relativePath.startsWith('/')) {
          relativePath = relativePath.substring('/'.length);
        }
      }
      return libraryPath + relativePath;
    }
    return relativePath;
  }
}
