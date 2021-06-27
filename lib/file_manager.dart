library file_manager;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

enum SortBy {
  name,
  date,
}

typedef TileBuilder = Widget Function(
  BuildContext context,
  FileSystemEntity entity,
);

bool isFile(FileSystemEntity entity) {
  return (entity is File);
}

bool isDirectory(FileSystemEntity entity) {
  return (entity is Directory);
}

/// Get the basename of Directory or File by providing FileSystemEntity entity.
/// ie: controller.dirName(dir);
String basename(FileSystemEntity entity, [bool showFileExtension = true]) {
  return (showFileExtension && (entity is File))
      ? entity.path.split('/').last.split('.').first
      : entity.path.split('/').last;
}

/// Get the basename of Directory by providing Directory.
String basenameDir(Directory dir) => dir.path.split('/').last;

/// Get the basename of Fileby providing File.
String basenameFle(File file, {bool showFileExtension = false}) =>
    showFileExtension
        ? file.path.split('/').last
        : file.path.split('/').last.split('.').first;

Future<List<Directory>?> getStorageList() async {
  List<Directory>? storages = await getExternalStorageDirectories();
  if (Platform.isAndroid) {
    storages = storages!.map((Directory e) {
      final List<String> splitedPath = e.path.split("/");
      return Directory(splitedPath
          .sublist(0, splitedPath.indexWhere((element) => element == "Android"))
          .join("/"));
    }).toList();
    return storages;
  } else
    return [];
}

class FileManegerController extends ChangeNotifier {
  String _path = "";
  int _currentStorage = 0;

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
  set setCurrentStorage(int index) {
    _currentStorage = index;
    notifyListeners();
  }

  bool handleWillPopScope() {
    return false;
  }
}

class FileManager extends StatefulWidget {
  /// Provide a custom widget for loading screen.
  final Widget? loadingScreen;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final FileManegerController controller;
  final TileBuilder tileBuilder;

  /// Hide the hidden file and folder.
  final bool hideHiddenEntity;

  FileManager({
    this.loadingScreen,
    this.physics,
    this.shrinkWrap = false,
    required this.controller,
    required this.tileBuilder,
    this.hideHiddenEntity = true,
  });

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  final ValueNotifier<String> path = ValueNotifier<String>("");
  final ValueNotifier<int> currentStorage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      path.value = widget.controller.getCurrentPath;
      currentStorage.value = widget.controller.getCurrentStorage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Directory>?>(
      future: getStorageList(),
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.hasData) {
          path.value = snapshot.data![0].path;
          return body(context);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return errorPage(snapshot.error.toString());
        } else {
          return loadingScreenWidget();
        }
      },
    );
  }

  Widget body(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: path,
        builder: (context, pathSnapshot, _) {
          return FutureBuilder<List<FileSystemEntity>>(
              future: Directory(pathSnapshot).list(recursive: false).toList(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<FileSystemEntity> entitys = snapshot.data!;
                  entitys.sort((a, b) =>
                      a.path.toLowerCase().compareTo(b.path.toLowerCase()));

                  if (widget.hideHiddenEntity) {
                    entitys = entitys.where((element) {
                      if (basename(element) == "" ||
                          basename(element).startsWith('.')) {
                        return false;
                      } else {
                        print(basename(element));
                        return true;
                      }
                    }).toList();
                  }

                  return ListView.builder(
                    physics: widget.physics,
                    shrinkWrap: widget.shrinkWrap,
                    itemCount: entitys.length,
                    itemBuilder: (context, index) {
                      return widget.tileBuilder(context, entitys[index]);
                    },
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return errorPage(snapshot.error.toString());
                } else {
                  return loadingScreenWidget();
                }
              });
        },
      );

  // Widget tileWidget(BuildContext context, FileSystemEntity entity) {
  //   return widget.tileBuilder(context, entity);
  // }

  Container errorPage(String error) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Text("Error: $error"),
      ),
    );
  }

  Widget loadingScreenWidget() {
    return (widget.loadingScreen == null)
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            child: Center(
            child: widget.loadingScreen,
          ));
  }
}
