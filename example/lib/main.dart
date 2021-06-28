import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final FileManagerController controller = FileManagerController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.willPopScopeControll,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => controller.setCurrentStorage(strageIndex: 1),
                icon: Icon(Icons.sd_storage_rounded),
              )
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                
                final bool k = await controller.goToParentDirectory();
                print(k);
              },
            ),
          ),
          body: Container(
            margin: EdgeInsets.all(10),
            child: FileManager(
              controller: controller,
              tileBuilder: (context, entity) {
                return Card(
                  child: ListTile(
                    leading: isFile(entity)
                        ? Icon(Icons.feed_outlined)
                        : Icon(Icons.folder),
                    title: Text(basename(entity, false)),
                    onTap: () {
                      if (isDirectory(entity)) controller.openDirectory(entity);
                    },
                  ),
                );
              },
            ),
          )),
    );
  }
}
