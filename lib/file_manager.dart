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
  final DateTime fileStat;
  _PathStat(this.path, this.fileStat);
}

Future<List<FileSystemEntity>> _sortEntitysList(
    String path, SortBy sortType) async {
  final List<FileSystemEntity> list = await Directory(path).list().toList();
  if (sortType == SortBy.name) {
    final dirs = list.where((element) => element is Directory).toList();
    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    final files = list.where((element) => element is File).toList();
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    return [...dirs, ...files];
  } else if (sortType == SortBy.date) {
    List<_PathStat> _pathStat = [];
    for (FileSystemEntity e in list) {
      _pathStat.add(_PathStat(e.path, (await e.stat()).modified));
    }
    list.sort((a, b) => _pathStat
        .indexWhere((element) => element.path == a.path)
        .compareTo(_pathStat.indexWhere((element) => element.path == b.path)));
    return list;
  } else if (sortType == SortBy.type) {
    final dirs = list.where((element) => element is Directory).toList();
    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    final files = list.where((element) => element is File).toList();
    files.sort((a, b) => a.path
        .toLowerCase()
        .split('.')
        .last
        .compareTo(b.path.toLowerCase().split('.').last));
    return [...dirs, ...files];
  }
  return [];
}

bool isFile(FileSystemEntity entity) {
  return (entity is File);
}

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
          throw Exception(snapshot.error.toString());
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
