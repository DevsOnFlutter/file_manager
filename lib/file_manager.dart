library file_manager;

import 'dart:io';
import 'dart:math' as math;
import 'package:file_manager/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:file_manager/helper/helper.dart';
export 'package:file_manager/helper/helper.dart';

const _methodChannel = MethodChannel('myapp/channel');

typedef _Builder = Widget Function(
  BuildContext context,
  List<FileSystemEntity> snapshot,
);

typedef _ErrorBuilder = Widget Function(
  BuildContext context,
  Object? error,
);

/// FileManager is a wonderful widget that allows you to manage files and folders, pick files and folders, and do a lot more.
/// Designed to feel like part of the Flutter framework.
///
/// Sample code
///```dart
///FileManager(
///    controller: controller,
///    builder: (context, snapshot) {
///    final List<FileSystemEntity> entitis = snapshot;
///      return ListView.builder(
///        itemCount: entitis.length,
///        itemBuilder: (context, index) {
///          return Card(
///            child: ListTile(
///              leading: FileManager.isFile(entitis[index])
///                  ? Icon(Icons.feed_outlined)
///                  : Icon(Icons.folder),
///              title: Text(FileManager.basename(entitis[index])),
///              onTap: () {
///                if (FileManager.isDirectory(entitis[index])) {
///                    controller
///                     .openDirectory(entitis[index]);
///                  } else {
///                      // Perform file-related tasks.
///                  }
///              },
///            ),
///          );
///        },
///      );
///  },
///),
///```
class FileManager extends StatefulWidget {
  /// For the loading screen, create a custom widget.
  /// Simple Centered CircularProgressIndicator is provided by default.
  final Widget? loadingScreen;

  /// For an empty screen, create a custom widget.
  final Widget? emptyFolder;

  /// For an error screen, create a custom widget.
  final _ErrorBuilder? errorBuilder;

  ///Controls the state of the FileManager.
  final FileManagerController controller;

  ///This function allows you to create custom widgets and retrieve a list of entities `List<FileSystemEntity>.`
  ///
  ///
  ///```
  /// builder: (context, snapshot) {
  ///               return ListView.builder(
  ///                 itemCount: snapshot.length,
  ///                 itemBuilder: (context, index) {
  ///                   return Card(
  ///                     child: ListTile(
  ///                       leading: FileManager.isFile(snapshot[index])
  ///                           ? Icon(Icons.feed_outlined)
  ///                           : Icon(Icons.folder),
  ///                       title: Text(FileManager.basename(snapshot[index])),
  ///                       onTap: () {
  ///                         if (FileManager.isDirectory(snapshot[index]))
  ///                           controller.openDirectory(snapshot[index]);
  ///                       },
  ///                     ),
  ///                   );
  ///                 },
  ///               );
  ///             },
  /// ```
  final _Builder builder;

  /// Hide the files and folders that are hidden.
  final bool hideHiddenEntity;

  FileManager({
    this.emptyFolder,
    this.loadingScreen,
    this.errorBuilder,
    required this.controller,
    required this.builder,
    this.hideHiddenEntity = true,
  });

  @override
  _FileManagerState createState() => _FileManagerState();

  static Future<void> requestFilesAccessPermission() async {
    if (Platform.isAndroid) {
      try {
        await _methodChannel.invokeMethod('requestFilesAccessPermission');
      } on PlatformException catch (e) {
        throw e;
      }
    } else {
      throw UnsupportedError('Only Android is supported');
    }
  }

  /// check weather FileSystemEntity is File
  /// return true if FileSystemEntity is File else returns false
  static bool isFile(FileSystemEntity entity) {
    return (entity is File);
  }

// check weather FileSystemEntity is Directory
  /// return true if FileSystemEntity is a Directory else returns Directory
  static bool isDirectory(FileSystemEntity entity) {
    return (entity is Directory);
  }

  /// Get the basename of Directory or File.
  ///
  /// Provide [File], [Directory] or [FileSystemEntity] and returns the name as a [String].
  ///
  /// ie:
  /// ```dart
  /// controller.basename(dir);
  /// ```
  /// to hide the extension of file, showFileExtension = flase
  static String basename(dynamic entity, {bool showFileExtension = true}) {
    if (entity is! FileSystemEntity) return "";

    final pathSegments = entity.path.split('/');
    final filename = pathSegments.last;

    if (showFileExtension) return filename;

    return showFileExtension ? filename.split('.').first : filename;
  }

  static const int base = 1024;
  static const List<String> suffix = ['B', 'KB', 'MB', 'GB', 'TB'];
  static const List<int> powBase = [
    1,
    1024,
    1048576,
    1073741824,
    1099511627776
  ];

  /// Format bytes to human readable string.
  static String formatBytes(int bytes, [int precision = 2]) {
    final base = (bytes == 0) ? 0 : (math.log(bytes) / math.log(1024)).floor();
    final size = bytes / powBase[base];
    final formattedSize = size.toStringAsFixed(precision);
    return '$formattedSize ${suffix[base]}';
  }

  /// Creates the directory if it doesn't exist.
  static Future<void> createFolder(String currentPath, String name) async {
    await Directory(currentPath + "/" + name).create();
  }

  /// Return file extension as String.
  ///
  /// ie:- `File("/../image.png")` to `"png"`
  static String getFileExtension(FileSystemEntity file) {
    if (file is File) {
      return file.path.split("/").last.split('.').last;
    } else {
      throw "FileSystemEntity is Directory, not a File";
    }
  }

  /// Get list of available storage in the device
  /// returns an empty list if there is no storage
  static Future<List<Directory>> getStorageList() async {
    if (Platform.isAndroid) {
      List<Directory> storages = (await getExternalStorageDirectories())!;
      storages = storages.map((Directory e) {
        final List<String> splitedPath = e.path.split("/");
        return Directory(splitedPath
            .sublist(
                0, splitedPath.indexWhere((element) => element == "Android"))
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
}

class _FileManagerState extends State<FileManager> {
  Future<List<Directory>?>? currentDir;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller.getCurrentPath.isNotEmpty) {
      currentDir = Future.value([widget.controller.getCurrentDirectory]);
    } else {
      currentDir = FileManager.getStorageList();
    }
  }

  Future<List<FileSystemEntity>> entityList(
      String path, SortBy sortBy, bool refresh) async {
    List<FileSystemEntity> entitys = refresh
        ? await Directory(path).list().toList()
        : await Directory(path).list().toList();
    switch (sortBy) {
      case SortBy.name:
        return entitys.sortByName;
      case SortBy.size:
        return entitys.sortBySize;
      case SortBy.date:
        return entitys.sortByDate;
      case SortBy.type:
        return entitys.sortByType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Directory>?>(
      future: currentDir,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          widget.controller.setCurrentPath = snapshot.data!.first.path;
          return _body(context);
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return _errorPage(context, snapshot.error);
        } else {
          return _loadingScreenWidget();
        }
      },
    );
  }

  Widget _body(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.controller.getPathNotifier,
      builder: (context, pathSnapshot, _) {
        return ValueListenableBuilder<SortBy>(
            valueListenable: widget.controller.getSortedByNotifier,
            builder: (context, snapshot, _) {
              return ValueListenableBuilder<bool>(
                  valueListenable: widget.controller.getRefreshNotifier,
                  builder: (context, refreshSnapshot, _) {
                    return FutureBuilder<List<FileSystemEntity>>(
                        future: entityList(
                            pathSnapshot,
                            widget.controller.getSortedByNotifier.value,
                            refreshSnapshot),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<FileSystemEntity> entitys = snapshot.data!;
                            if (entitys.length == 0) {
                              return _emptyFolderWidget();
                            }
                            if (widget.hideHiddenEntity) {
                              entitys = entitys.where((element) {
                                if (FileManager.basename(element) == "" ||
                                    FileManager.basename(element)
                                        .startsWith('.')) {
                                  return false;
                                } else {
                                  return true;
                                }
                              }).toList();
                            }
                            return widget.builder(context, entitys);
                          } else if (snapshot.hasError) {
                            print(snapshot.error);
                            return _errorPage(context, snapshot.error);
                          } else {
                            return _loadingScreenWidget();
                          }
                        });
                  });
            });
      },
    );
  }

  Widget _emptyFolderWidget() {
    if (widget.emptyFolder == null) {
      return Container(
        child: Center(child: Text("Empty Directory")),
      );
    } else
      return widget.emptyFolder!;
  }

  Widget _errorPage(BuildContext context, Object? error) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!(context, error);
    }
    return Container(
      color: Colors.red,
      child: Center(
        child: Text("Error: $error"),
      ),
    );
  }

  Widget _loadingScreenWidget() {
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

/// When the current directory is not root, this widget registers a callback to prevent the user from dismissing the window
/// , or controllers the system's back button
///
/// #### Wrap Scaffold containing FileManage with `ControlBackButton`
/// ```dart
/// ControlBackButton(
///   controller: controller
///   child: Scaffold(
///     appBar: AppBar(...)
///     body: FileManager(
///       ...
///     )
///   )
/// )
/// ```
class ControlBackButton extends StatelessWidget {
  const ControlBackButton(
      {required this.child, required this.controller, Key? key})
      : super(key: key);

  final Widget child;
  final FileManagerController controller;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: child,
      onWillPop: () async {
        if (await controller.isRootDirectory()) {
          return true;
        } else {
          controller.goToParentDirectory();
          return false;
        }
      },
    );
  }
}
