package com.example.jejal_project

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.jejal_project.OverlayPermissionActivity

// overlay 권한 관리
class MainActivity : FlutterActivity() {
    // MethodChannel을 위한 채널 이름을 정의
    private val CHANNEL = "overlay_permission"

    // FlutterEngine을 구성하는 메서드
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // MethodChannel을 생성하고, Flutter에서 메서드 호출을 처리할 핸들러를 설정
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            // 호출된 메서드가 "requestOverlayPermission"인 경우, 오버레이 권한을 요청
            if (call.method == "requestOverlayPermission") {
                requestOverlayPermission(result)
            } else {
                result.notImplemented()
            }
        }
    }

    // 오버레이 권한을 요청하는 메서드
    private fun requestOverlayPermission(result: MethodChannel.Result) {
        // 안드로이드 버전이 마시멜로우(API 레벨 23) 이상인 경우에만 실행
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // 오버레이 권한이 없는 경우, OverlayPermissionActivity를 실행하여 권한을 요청
            if (!Settings.canDrawOverlays(this)) {
                OverlayPermissionActivity.requestOverlayPermission(this)
                // 권한 요청 결과를 처리하기 위해 MethodChannel.Result 객체를 저장
                overlayPermissionResult = result
            } else {
                // 오버레이 권한이 있는 경우, 성공 결과를 전달
                result.success(true)
            }
        } else {
            // 안드로이드 버전이 마시멜로우(API 레벨 23) 미만인 경우, 오버레이 권한이 필요하지 않으므로 성공 결과를 전달
            result.success(true)
        }
    }

    // 오버레이 권한 요청 코드를 정의
    companion object {
        private const val OVERLAY_PERMISSION_REQUEST_CODE = 1
    }

    // 오버레이 권한 요청 결과를 처리하기 위한 MethodChannel.Result 객체를 저장하기 위한 변수
    private var overlayPermissionResult: MethodChannel.Result? = null

    // 오버레이 권한 요청에 대한 결과를 처리하는 메서드
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // requestCode가 오버레이 권한 요청 코드와 일치하는 경우에만 실행
        if (requestCode == OVERLAY_PERMISSION_REQUEST_CODE) {
            // 안드로이드 버전이 마시멜로우(API 레벨 23) 이상인 경우에만 실행
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // 오버레이 권한 요청 결과를 MethodChannel을 통해 Flutter로 전달
                overlayPermissionResult?.success(Settings.canDrawOverlays(this))
            }
        }
    }
}