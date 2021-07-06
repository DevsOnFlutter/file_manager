import 'dart:async';
import 'dart:io';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

class FileManagerController extends ChangeNotifier {
  StreamController<String> pathStream = StreamController<String>.broadcast();
  StreamController<String> titleStream = StreamController<String>.broadcast();
  String _path = "";
  SortBy _short = SortBy.size;

  _updatePath(String path) {
    pathStream.add(path);
    _path = path;
    titleStream.add(path.split('/').last);
  }

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
    _updatePath(path);
    notifyListeners();
  }

  /// return true if current directory is the root. false, if the current directory not on root of the stogare.
  Future<bool> isRootDirectory() async {
    final List<Directory> storageList = (await getStorageList());
    return (storageList
        .where((element) => element.path == Directory(_path).path)
        .isNotEmpty);
  }

  /// Jumps to the parent directory of currently opened directory if the parent is accessible.
  Future<void> goToParentDirectory() async {
    if (!(await isRootDirectory())) openDirectory(Directory(_path).parent);
  }

  /// Open directory by providing [Directory].
  void openDirectory(FileSystemEntity entity) {
    if (entity is Directory) {
      _updatePath(entity.path);
      notifyListeners();
    } else {
      throw ("FileSystemEntity entity is File. Please provide a Directory(folder) to be opened not File");
    }
  }

  @override
  void dispose() {
    super.dispose();
    pathStream.close();
    titleStream.close();
  }
}
