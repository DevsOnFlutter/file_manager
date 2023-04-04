package com.example.example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.provider.Settings
import android.content.Intent
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val MANAGE_STORAGE_RC = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "myapp/channel").setMethodCallHandler { call: MethodCall, result: Result ->
            if (call.method == "requestFilesAccessPermission") {
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION)
                intent.addCategory(Intent.CATEGORY_DEFAULT)
                intent.data = Uri.parse("package:$packageName")
                startActivityForResult(intent, MANAGE_STORAGE_RC)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
