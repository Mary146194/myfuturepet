package com.example.myfuturepet

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Google Play lists ARCore-capable phones by this system feature.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "myfuturepet/ar_support")
            .setMethodCallHandler { call, result ->
                if (call.method == "check") {
                    val supported = packageManager.hasSystemFeature("android.hardware.camera.ar")
                    result.success(if (supported) "supported" else "unsupported")
                } else {
                    result.notImplemented()
                }
            }
    }
}
