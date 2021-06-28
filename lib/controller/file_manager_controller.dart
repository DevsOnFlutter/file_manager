import 'dart:io';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class FileManagerController extends ChangeNotifier {
  String _path = "";
  int _currentStorage = 0;
  SortBy _short = SortBy.name;

  // TODO: [Documentation]
  SortBy get getSortedBy => _short;
  // TODO: [Documentation]
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

  Future<bool> goToParentDirectory() async {
    List<Directory> storageList = (await getStorageList())!;
    final bool willNotGoToParent = (storageList
        .where((element) => element.path == Directory(_path).path)
        .isNotEmpty);
    if (!willNotGoToParent) openDirectory(Directory(_path).parent);
    return willNotGoToParent;
  }

  Future<bool> willPopScopeControll() async {
    return await goToParentDirectory();
  }

  Future<void> sortBy(SortBy sortType) async {
    if (sortType == SortBy.name) {}
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
  Future<void> setCurrentStorage({required int strageIndex}) async {
    _currentStorage = strageIndex;
    _path = (await getStorageList())![strageIndex].path;
    notifyListeners();
  }

  bool handleWillPopScope() {
    return false;
  }
}
