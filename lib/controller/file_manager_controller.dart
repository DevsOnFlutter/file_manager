import 'dart:io';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class FileManagerController extends ChangeNotifier {
  String _path = "";
  int _currentStorage = 0;
  SortBy _short = SortBy.size;

  // TODO: [Documentation]

  /// getSorted by returns the current sorting type of the FileManager
  SortBy get getSortedBy => _short;
  // TODO: [Documentation]
  /// setSortedBy is used to set the sorting type. 
  set setSortedBy(SortBy sortType) {
    _short = sortType;
    notifyListeners();
  }

  /// Get current directory path.
  Directory get getCurrentDirectory => Directory(_path);
  String get getCurrentPath {
    return _path;
  }

  /// Set current directory path by providing string of path.
  set setCurrentPath(String path) {
    _path = path;
    notifyListeners();
  }

  // TODO: [Documentation]
  /// goToParentDirectory returns false and goes to the parent directory of currently opened directory if the parent is accessible,
  /// it will return true and pops the screen if the parent of currently opened directory is not accessible.
  Future<bool> goToParentDirectory() async {
    List<Directory> storageList = (await getStorageList())!;
    final bool willNotGoToParent = (storageList
        .where((element) => element.path == Directory(_path).path)
        .isNotEmpty);
    if (!willNotGoToParent) openDirectory(Directory(_path).parent);
    return willNotGoToParent;
  }

  /// Open directory by providing Directory.
  void openDirectory(FileSystemEntity entity) {
    if (entity is Directory) {
      _path = entity.path;
      notifyListeners();
    } else {
      print(
          "FileSystemEntity entity is File. Please provide a Directory(folder) to be opened not File");
    }
  }

  /// Get current storege. ie: 0 is for internal storage. 1, 2 and so on, if any external storage is available.
  int get getCurrentStorage => _currentStorage;

  /// Set current storege. ie: 0 is for internal storage. 1, 2 and so on, if any external storage is available.
  Future<void> setCurrentStorage({required int storageIndex}) async {
    _currentStorage = storageIndex;
    _path = (await getStorageList())![storageIndex].path;
    notifyListeners();
  }
}
