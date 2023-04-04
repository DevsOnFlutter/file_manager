import 'dart:io';

class _PathStat {
  final String path;
  final DateTime dateTime;

  const _PathStat(this.path, this.dateTime);
}

extension FileSystemEntityExtensions on List<FileSystemEntity> {
  Future<List<FileSystemEntity>> get sortByName async {
    final List<Directory> dirs = [];
    final List<File> files = [];

    for (final entity in this) {
      if (entity is Directory) {
        dirs.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    return [...dirs, ...files];
  }

  Future<List<FileSystemEntity>> get sortByDate async {
    final List<_PathStat> _pathStat = [];

    for (final entity in this) {
      final stat = await entity.stat();
      _pathStat.add(_PathStat(entity.path, stat.modified));
    }

    _pathStat.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return _pathStat
        .map((pathStat) =>
            this.firstWhere((entity) => entity.path == pathStat.path))
        .toList();
  }

  Future<List<FileSystemEntity>> get sortByType async {
    final List<Directory> dirs = [];
    final List<File> files = [];

    for (final entity in this) {
      if (entity is Directory) {
        dirs.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.sort((a, b) => a.path
        .toLowerCase()
        .split('.')
        .last
        .compareTo(b.path.toLowerCase().split('.').last));

    return [...dirs, ...files];
  }

  Future<List<FileSystemEntity>> get sortBySize async {
    final List<File> files = [];
    final List<Directory> dirs = [];

    for (final entity in this) {
      if (entity is Directory) {
        dirs.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    dirs.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
    this.clear();
    this.addAll([...dirs, ...files]);

    return this;
  }
}
