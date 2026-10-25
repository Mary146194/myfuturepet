package com.example.myfuturepet

import android.os.Handler
import android.os.Looper
import com.google.ar.core.ArCoreApk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "myfuturepet/ar_support")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "check" -> checkArCore(result, attemptsLeft = 25)
                    "install" -> requestArCoreInstall(result)
                    else -> result.notImplemented()
                }
            }
    }

    // Asks Google Play Services for AR's device list. Few phones declare the
    // android.hardware.camera.ar feature even when ARCore supports them, so
    // that flag alone wrongly reported "unsupported".
    private fun checkArCore(result: MethodChannel.Result, attemptsLeft: Int) {
        if (packageManager.hasSystemFeature("android.hardware.camera.ar")) {
            result.success("supported")
            return
        }
        val availability = try {
            ArCoreApk.getInstance().checkAvailability(this)
        } catch (e: Exception) {
            result.success("unknown:${e.javaClass.simpleName}")
            return
        }
        when {
            // The first call may still be asking Google; poll briefly.
            availability.isTransient && attemptsLeft > 0 ->
                Handler(Looper.getMainLooper()).postDelayed(
                    { checkArCore(result, attemptsLeft - 1) }, 200
                )
            availability == ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED ||
                availability == ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD ->
                result.success("needs_install")
            availability.isSupported -> result.success("supported")
            availability == ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE ->
                result.success("unsupported")
            // The reason is shown on screen so a failed check can be diagnosed.
            else -> result.success("unknown:${availability.name}")
        }
    }

    // Shows Google's install/update screen for Play Services for AR.
    private fun requestArCoreInstall(result: MethodChannel.Result) {
        try {
            val status = ArCoreApk.getInstance().requestInstall(this, true)
            result.success(status.name)
        } catch (e: Exception) {
            result.success("failed")
        }
    }
}
