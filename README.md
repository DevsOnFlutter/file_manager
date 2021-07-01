# File Manager

<img src="https://i.imgur.com/NNaUK60.png"></img>

![GitHub](https://img.shields.io/github/license/DevsOnFlutter/file_manager?style=plastic) ![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/DevsOnFlutter/file_manager?style=plastic) ![GitHub top language](https://img.shields.io/github/languages/top/DevsOnFlutter/file_manager?style=plastic) ![GitHub language count](https://img.shields.io/github/languages/count/DevsOnFlutter/file_manager?style=plastic) ![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/DevsOnFlutter/file_manager?style=plastic) ![GitHub issues](https://img.shields.io/github/issues/DevsOnFlutter/file_manager?style=plastic) 

![GitHub Repo stars](https://img.shields.io/github/stars/DevsOnFlutter/file_manager?style=social) ![GitHub forks](https://img.shields.io/github/forks/DevsOnFlutter/file_manager?style=social)

FileManager is a wonderful widget that allows you to manage files and folders, pick files and folders, and do a lot more.
Designed to feel like part of the Flutter framework.


## Usage

Make sure to check out [examples](https://github.com/DevsOnFlutter/file_manager/blob/main/example/lib/main.dart) for more details.

### Installation

Give storage permission to application

Beside needing to add **WRITE_EXTERNAL_STORAGE** and **READ_EXTERNAL_STORAGE** to your android/app/src/main/AndroidManifest.xml.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.xxx.yyy">
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

    <application
      android:requestLegacyExternalStorage="true"   
      ...
...
</manifest>
```
also add for Android 10
```
    <application
      android:requestLegacyExternalStorage="true"   
      ...
```

**You also need Runtime Request Permission**
allow storage permission from app setting manually or you may use any package such as [`permission_handler`](https://pub.dev/packages/permission_handler).

Add the following line to `pubspec.yaml`:

```yaml
dependencies:
  file_manager: ^1.0.0
```

### Basic setup

*The complete example is available [here](https://github.com/DevsOnFlutter/file_manager/blob/main/example/lib/main.dart).*

Required parameter for **FileManager** are `controller` and `builder`
* `controller` The controller updates value and notifies its listeners, and FileManager updates itself appropriately whenever the user modifies the path or changes the sort-type with an associated FileManagerController.
```
final FileManagerController controller = FileManagerController();
```
* `builder` This function allows you to create custom widgets and retrieve a list of entities `List<FileSystemEntity>.`



Sample code
```dart
FileManager(
    controller: controller,
    builder: (context, snapshot) {
    final List<FileSystemEntity> entities = snapshot;
      return ListView.builder(
        itemCount: entities.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: isFile(entities[index])
                  ? Icon(Icons.feed_outlined)
                  : Icon(Icons.folder),
              title: Text(basename(entities[index])),
              onTap: () {
                if (isDirectory(entities[index])) {
                    controller.openDirectory(entities[index]);   // open directory
                  } else {
                      // Perform file-related tasks.
                  }
              },
            ),
          );
        },
      );
  },
),
```

## FileManager
|  Properties  |   Description   |
|--------------|-----------------|
| `loadingScreen` | For the loading screen, create a custom widget. A simple Centered CircularProgressIndicator is provided by default. |
| `emptyFolder` | For an empty screen, create a custom widget. |
| `controller` | For an empty screen, create a custom widget. |
| `hideHiddenEntity` | Hide the files and folders that are hidden. |
| `builder` | This function allows you to create custom widgets and retrieve a list of entities `List<FileSystemEntity>.` |

## FileManagerContoller
|  Properties  |   Description   |
|--------------|-----------------|
| `getSortedBy` | The sorting type that is currently in use is returned. |
| `setSortedBy` | is used to set the sorting type. `SortBy{ name, type, date, size }`. |
| `getCurrentDirectory` | Get current Directory |
| `getCurrentPath` | Get current path, similar to [getCurrentDirectory]. |
| `setCurrentPath` | Set current directory path by providing `String` of path, similar to [openDirectory]. `List<FileSystemEntity>.` |
| `goToParentDirectory` | `goToParentDirectory` returns `bool`, goes to the parent directory of currently opened directory if the parent is accessible,  return true if current directory is the root. false, if the current directory not on root of the stogare.. |
| `openDirectory` | Open directory by providing `Directory`. |

## Others
|  Properties  |   Description   |
|--------------|-----------------|
| `isFile` | check weather FileSystemEntity is File. |
| `isDirectory` | check weather FileSystemEntity is Directory. |
| `basename` | Get the basename of Directory or File. Provide `File`, `Directory` or `FileSystemEntity` and returns the name as a `String`. If you want to hide the extension of a file, you may use optional parameter `showFileExtension`. ie ```controller.dirName(dir, true)```
|
| `formatBytes` | Convert bytes to human readable size.[getCurrentDirectory]. |
| `setCurrentPath` | Set current directory path by providing `String` of path, similar to [openDirectory]. `List<FileSystemEntity>.` |
| `getStorageList` | Get list of available storage in the device, returns an empty list if there is no storage `List<Directory>`|

## Show some :heart: and :star: the repo

## Project Created & Maintained By

### Alok Kumar

[![GitHub followers](https://img.shields.io/github/followers/4-alok?style=social)](https://github.com/4-alok/)

### Arpit Sahu

[![GitHub followers](https://img.shields.io/github/followers/Arpit-Sahu?style=social)](https://github.com/Arpit-Sahu/)

## Contributions

Contributions are welcomed!

If you feel that a hook is missing, feel free to open a pull-request.

For a custom-hook to be merged, you will need to do the following:

- Describe the use-case.

-  Open an issue explaining why we need this hook, how to use it, ...
  This is important as a hook will not get merged if the hook doens't appeal to
  a large number of people.

-  If your hook is rejected, don't worry! A rejection doesn't mean that it won't
  be merged later in the future if more people shows an interest in it.
  In the mean-time, feel free to publish your hook as a package on https://pub.dev.

-  A hook will not be merged unles fully tested, to avoid breaking it inadvertendly
  in the future.
