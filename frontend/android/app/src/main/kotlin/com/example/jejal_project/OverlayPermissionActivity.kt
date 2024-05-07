package com.example.jejal_project

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity

// 오버레이 권한을 요청하는 기능을 담은 OverlayPermissionActivity 클래스를 정의
object OverlayPermissionActivity {
    fun requestOverlayPermission(context: Context) {
        // 오버레이 권한이 없는 경우에만 실행
        if (!Settings.canDrawOverlays(context)) {
            // 오버레이 권한 설정을 위한 인텐트를 생성
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:${context.packageName}")
            )
            // 오버레이 권한 설정 액티비티를 시작. 결과를 받기 위해 startActivityForResult를 사용
            ActivityCompat.startActivityForResult(context as FlutterActivity, intent, 0, null)
        }
    }
}