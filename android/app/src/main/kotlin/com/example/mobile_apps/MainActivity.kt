package com.example.mobile_apps

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.diginews.native/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "reverseString" -> {
                    val nim = call.argument<String>("nim")
                    if (nim != null) {
                        val reversedNim = nim.reversed()
                        // Kirim kembali String yang sudah dibalik ke Flutter
                        result.success(reversedNim)
                    } else {
                        result.error("INVALID_ARGUMENT", "NIM is null", null)
                    }
                }
                "showToast" -> {
                    val message = call.argument<String>("message")
                    if (message != null) {
                        // Menampilkan Toast Native Android
                        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Message is null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
