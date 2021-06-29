library file_manager;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Library Imports
import 'package:file_manager/helper/helper.dart';
export 'package:file_manager/helper/helper.dart';

typedef _Builder = Widget Function(
  BuildContext context,
  List<FileSystemEntity> snapshot,
);

class _PathStat {
  final String path;
  final DateTime dateTime;
  _PathStat(this.path, this.dateTime);
}

Future<List<FileSystemEntity>> _sortEntitysList(
    String path, SortBy sortType) async {
  final List<FileSystemEntity> list = await Directory(path).list().toList();
  if (sortType == SortBy.name) {
    // making list of only folders.
    final dirs = list.where((element) => element is Directory).toList();
    // sorting folder list by name.
    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    // making list of only flies.
    final files = list.where((element) => element is File).toList();
    // sorting files list by name.
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    // first folders will go to list (if available) then files will go to list.
    return [...dirs, ...files];
  } else if (sortType == SortBy.date) {
    // making the list of Path & DateTime
    List<_PathStat> _pathStat = [];
    for (FileSystemEntity e in list) {
      _pathStat.add(_PathStat(e.path, (await e.stat()).modified));
    }

    // sort _pathStat according to date
    _pathStat.sort((b, a) => a.dateTime.compareTo(b.dateTime));

    // sorting [list] accroding to [_pathStat]
    list.sort((a, b) => _pathStat
        .indexWhere((element) => element.path == a.path)
        .compareTo(_pathStat.indexWhere((element) => element.path == b.path)));
    return list;
  } else if (sortType == SortBy.type) {
    // making list of only folders.
    final dirs = list.where((element) => element is Directory).toList();

    // sorting folders by name.
    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    // making the list of files
    final files = list.where((element) => element is File).toList();

    // sorting files list by extension.
    files.sort((a, b) => a.path
        .toLowerCase()
        .split('.')
        .last
        .compareTo(b.path.toLowerCase().split('.').last));
    return [...dirs, ...files];
  }
  return [];
}

// check weather FileSystemEntity is Fille
bool isFile(FileSystemEntity entity) {
  return (entity is File);
}

// check weather FileSystemEntity is Directory
bool isDirectory(FileSystemEntity entity) {
  return (entity is Directory);
}

/// Get the basename of Directory or File.
/// ie: controller.dirName(dir);
String basename(dynamic entity, [bool showFileExtension = true]) {
  if (entity is Directory) {
    return entity.path.split('/').last;
  } else if (entity is File) {
    return (showFileExtension)
        ? entity.path.split('/').last.split('.').first
        : entity.path.split('/').last;
  } else {
    print(
        "Please provide a Object of type File, Directory or FileSystemEntity");
    return "";
  }
}

// Get list of available storage directories
Future<List<Directory>?> getStorageList() async {
  if (Platform.isAndroid) {
    List<Directory> storages = (await getExternalStorageDirectories())!;
    storages = storages.map((Directory e) {
      final List<String> splitedPath = e.path.split("/");
      return Directory(splitedPath
          .sublist(0, splitedPath.indexWhere((element) => element == "Android"))
          .join("/"));
    }).toList();
    return storages;
  } else if (Platform.isLinux) {
    print("HEre");
    Directory dir = await getApplicationDocumentsDirectory();
    return [dir.parent];
  }
  return [];
}

class FileManager extends StatefulWidget {
  /// Provide a custom widget for loading screen.
  final Widget? loadingScreen;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final FileManagerController controller;
  final _Builder builder;

  /// Hide the hidden file and folder.
  final bool hideHiddenEntity;

  FileManager({
    this.loadingScreen,
    this.physics,
    this.shrinkWrap = false,
    required this.controller,
    required this.builder,
    this.hideHiddenEntity = true,
  });

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  final ValueNotifier<String> path = ValueNotifier<String>("");
  final ValueNotifier<SortBy> sort = ValueNotifier<SortBy>(SortBy.name);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      path.value = widget.controller.getCurrentPath;
      sort.value = widget.controller.getSortedBy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Directory>?>(
      future: getStorageList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          widget.controller.setCurrentPath = snapshot.data![0].path;
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

  Widget body(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: path,
      builder: (context, pathSnapshot, _) {
        return ValueListenableBuilder<SortBy>(
            valueListenable: sort,
            builder: (context, snapshot, _) {
              return FutureBuilder<List<FileSystemEntity>>(
                  future: _sortEntitysList(pathSnapshot, sort.value),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<FileSystemEntity> entitys = snapshot.data!;
                      if (widget.hideHiddenEntity) {
                        entitys = entitys.where((element) {
                          if (basename(element) == "" ||
                              basename(element).startsWith('.')) {
                            return false;
                          } else {
                            return true;
                          }
                        }).toList();
                      }
                      return widget.builder(context, entitys);
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return errorPage(snapshot.error.toString());
                    } else {
                      return loadingScreenWidget();
                    }
                  });
            });
      },
    );
  }

  Container errorPage(String error) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Text("Error: $error"),
      ),
    );
  }

  Widget loadingScreenWidget() {
    if ((widget.loadingScreen == null)) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container(
        child: Center(
          child: widget.loadingScreen,
        ),
      );
    }
  }
}
