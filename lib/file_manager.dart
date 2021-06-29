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

///sort the files and folders according to the SortBy type
///It will return a list of fileSystemEntity after sorting
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
  } else if (sortType == SortBy.size) {
    // create list of path and size
    Map<String, int> _sizeMap = {};
    for (FileSystemEntity e in list) {
      _sizeMap[e.path] = (await e.stat()).size;
    }

    // making list of only folders.
    final dirs = list.where((element) => element is Directory).toList();
    // sorting folder list by name.
    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    // making list of only flies.
    final files = list.where((element) => element is File).toList();

    // creating sorted list of [_sizeMapList] by size.
    final List<MapEntry<String, int>> _sizeMapList = _sizeMap.entries.toList();
    _sizeMapList.sort((b, a) => a.value.compareTo(b.value));

    // sort [list] according to [_sizeMapList]
    files.sort((a, b) => _sizeMapList
        .indexWhere((element) => element.key == a.path)
        .compareTo(
            _sizeMapList.indexWhere((element) => element.key == b.path)));
    return [...dirs, ...files];
  }
  return [];
}

/// check weather FileSystemEntity is File
/// return true if FileSystemEntity is a File else returns false
bool isFile(FileSystemEntity entity) {
  return (entity is File);
}

// check weather FileSystemEntity is Directory
/// return true if FileSystemEntity is a Directory else returns Directory
bool isDirectory(FileSystemEntity entity) {
  return (entity is Directory);
}

/// Get the basename of Directory or File.
/// takes the directory and returns the name of file or folder
/// ie: controller.dirName(dir);
/// to hide the extension of file, showFileExtension = flase
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

/// Get list of available storage in the device
/// returns an empty list if there is no storage
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
    final Directory dir = await getApplicationDocumentsDirectory();

    // Gives the home directory.
    final Directory home = dir.parent;

    // you may provide root directory.
    // final Directory root = dir.parent.parent.parent;
    return [home];
  }
  return [];
}

class FileManager extends StatefulWidget {
  /// Provide a custom widget for loading screen.
  /// as default CircularProgressIndicator is provided.
  final Widget? loadingScreen;

  /// Provide a scroll Physics for scrolling behaviour.
  final ScrollPhysics? physics;

  ///shrinkwrap will only occupy the space it need
  final bool shrinkWrap;

  final FileManagerController controller;

  ///Builder is a custom builder which takes an entity and bulds a widget around it
  ///
  ///
  ///```
  /// builder: (context, snapshot) {
  ///               return ListView.builder(
  ///                 itemCount: snapshot.length,
  ///                 itemBuilder: (context, index) {
  ///                   return Card(
  ///                     child: ListTile(
  ///                       leading: isFile(snapshot[index])
  ///                           ? Icon(Icons.feed_outlined)
  ///                           : Icon(Icons.folder),
  ///                       title: Text(basename(snapshot[index])),
  ///                       onTap: () {
  ///                         if (isDirectory(snapshot[index]))
  ///                           controller.openDirectory(snapshot[index]);
  ///                       },
  ///                     ),
  ///                   );
  ///                 },
  ///               );
  ///             },
  /// ```
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

    /// add the listner to the contoller
    widget.controller.addListener(() {
      path.value = widget.controller.getCurrentPath;
      sort.value = widget.controller.getSortedBy;
    });
  }

  /// dispose all the value notifiers
  @override
  void dispose() {
    path.dispose();
    sort.dispose();
    super.dispose();
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

  /// main body of File Manager can fetch data from the device
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

  /// error page that displays the error in the screen
  Container errorPage(String error) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Text("Error: $error"),
      ),
    );
  }

  /// loading screen if the backend is currently fecthing data from the device.
  /// It will display simple Circular Progress Indicator if no custom widget is passed.
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
