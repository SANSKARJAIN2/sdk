// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pub.source.path;

import 'dart:async';

import 'package:path/path.dart' as path;

import '../io.dart';
import '../package.dart';
import '../pubspec.dart';
import '../source.dart';
import '../utils.dart';

/// A package [Source] that installs packages from a given local file path.
class PathSource extends Source {
  final name = 'path';
  final shouldCache = false;

  Future<Pubspec> describeUncached(PackageId id) {
    return new Future.sync(() {
      _validatePath(id.name, id.description);
      return new Pubspec.load(id.name, id.description["path"],
          systemCache.sources);
    });
  }

  bool descriptionsEqual(description1, description2) {
    // Compare real paths after normalizing and resolving symlinks.
    var path1 = canonicalize(description1["path"]);
    var path2 = canonicalize(description2["path"]);
    return path1 == path2;
  }

  Future<bool> install(PackageId id, String destination) {
    return new Future.sync(() {
      try {
        _validatePath(id.name, id.description);
      } on FormatException catch(err) {
        return false;
      }

      createPackageSymlink(id.name, id.description["path"], destination,
          relative: id.description["relative"]);
      return true;
    });
  }

  Future<String> getDirectory(PackageId id) {
    return newFuture(() {
      _validatePath(id.name, id.description);
      return id.description["path"];
    });
  }

  /// Parses a path dependency. This takes in a path string and returns a map.
  /// The "path" key will be the original path but resolved relative to the
  /// containing path. The "relative" key will be `true` if the original path
  /// was relative.
  ///
  /// A path coming from a pubspec is a simple string. From a lock file, it's
  /// an expanded {"path": ..., "relative": ...} map.
  dynamic parseDescription(String containingPath, description,
                           {bool fromLockFile: false}) {
    if (fromLockFile) {
      if (description is! Map) {
        throw new FormatException("The description must be a map.");
      }

      if (description["path"] is! String) {
        throw new FormatException("The 'path' field of the description must "
            "be a string.");
      }

      if (description["relative"] is! bool) {
        throw new FormatException("The 'relative' field of the description "
            "must be a boolean.");
      }

      return description;
    }

    if (description is! String) {
      throw new FormatException("The description must be a path string.");
    }

    // Resolve the path relative to the containing file path, and remember
    // whether the original path was relative or absolute.
    bool isRelative = path.isRelative(description);
    if (path.isRelative(description)) {
      // Can't handle relative paths coming from pubspecs that are not on the
      // local file system.
      assert(containingPath != null);

      description = path.join(path.dirname(containingPath), description);
    }

    return {
      "path": description,
      "relative": isRelative
    };
  }

  /// Ensures that [description] is a valid path description. It must be a map,
  /// with a "path" key containing a path that points to an existing directory.
  /// Throws an [ApplicationException] if the path is invalid.
  void _validatePath(String name, description) {
    var dir = description["path"];

    if (dirExists(dir)) return;

    if (fileExists(dir)) {
      fail("Path dependency for package '$name' must refer to a "
           "directory, not a file. Was '$dir'.");
    }

    fail("Could not find package '$name' at '$dir'.");
  }
}
