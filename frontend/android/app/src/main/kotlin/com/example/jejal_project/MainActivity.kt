<<<<<<< HEAD
package com.example.jejal_project

import android.content.Intent
import android.net.Uri
=======

package com.example.jejal_project

import android.content.Intent
import android.os.Bundle
>>>>>>> 6f09919dac175feb3bd4634f1fde1deb05cd503b
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
<<<<<<< HEAD
import com.example.jejal_project.OverlayPermissionActivity

class MainActivity : FlutterActivity() {
    private val CHANNEL = "overlay_permission"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
=======

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 포그라운드 서비스를 자동으로 시작
        val intent = Intent(this, YourForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    // overlay_permission"이라는 채널을 만들고, 이 채널을 통해 플러터 측에서 오버레이 권한을 요청
    ove                     rride fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "overlay_permission"
>>>>>>> 6f09919dac175feb3bd4634f1fde1deb05cd503b
        ).setMethodCallHandler { call, result ->
            if (call.method == "requestOverlayPermission") {
                requestOverlayPermission(result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun requestOverlayPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                OverlayPermissionActivity.requestOverlayPermission(this)
                overlayPermissionResult = result
            } else {
                result.success(true)
            }
        } else {
            result.success(true)
        }
    }

    companion object {
        private const val OVERLAY_PERMISSION_REQUEST_CODE = 1
    }

    private var overlayPermissionResult: MethodChannel.Result? = null

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OVERLAY_PERMISSION_REQUEST_CODE) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                overlayPermissionResult?.success(Settings.canDrawOverlays(this))
            }
        }
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> 6f09919dac175feb3bd4634f1fde1deb05cd503b