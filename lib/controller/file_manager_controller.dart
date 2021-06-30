import 'dart:io';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class FileManagerController extends ChangeNotifier {
  String _path = "";
  SortBy _short = SortBy.size;

  /// The sorting type that is currently in use is returned.
  SortBy get getSortedBy => _short;

  /// [setSortedBy] is used to set the sorting type.
  ///
  /// `SortBy{ name, type, date, size }`
  set sortedBy(SortBy sortType) {
    _short = sortType;
    notifyListeners();
  }

  /// Get current Directory.
  Directory get getCurrentDirectory => Directory(_path);

  /// Get current path, similar to [getCurrentDirectory].
  String get getCurrentPath => _path;

  /// Set current directory path by providing string of path, similar to [openDirectory].
  set setCurrentPath(String path) {
    _path = path;
    notifyListeners();
  }

  /// [goToParentDirectory] returns [bool], goes to the parent directory of currently opened directory if the parent is accessible,
  /// return true if current directory is the root. false, if the current directory not on root of the stogare.
  Future<bool> goToParentDirectory() async {
    List<Directory> storageList = (await getStorageList());
    final bool willNotGoToParent = (storageList
        .where((element) => element.path == Directory(_path).path)
        .isNotEmpty);
    if (!willNotGoToParent) openDirectory(Directory(_path).parent);
    return willNotGoToParent;
  }

  /// Open directory by providing [Directory].
  void openDirectory(FileSystemEntity entity) {
    if (entity is Directory) {
      _path = entity.path;
      notifyListeners();
    } else {
      throw ("FileSystemEntity entity is File. Please provide a Directory(folder) to be opened not File");
    }
  }
}
