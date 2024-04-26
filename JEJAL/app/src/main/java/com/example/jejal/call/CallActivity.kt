package com.example.jejal.call

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import com.example.jejal.R
import com.example.jejal.call.CallOverlayService

class CallActivity : AppCompatActivity() {
    // 전화 중 녹음 보내기 관련 activity
    // 전화 중 팝업 띄우기 관련 activity

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_call_page)

        // 오버레이 권한 확인 및 요청
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
            startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST_CODE)
        } else {
            startCallOverlayService()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OVERLAY_PERMISSION_REQUEST_CODE) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && Settings.canDrawOverlays(this)) {
                startCallOverlayService()
            } else {
                // 오버레이 권한이 거부된 경우 처리
            }
        }
    }

    private fun startCallOverlayService() {
        val intent = Intent(this, CallOverlayService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Android 8.0 이상에서는 startForegroundService()를 사용하여 포그라운드 서비스 시작
            startForegroundService(intent)
        } else {
            // Android 8.0 미만에서는 startService()를 사용하여 서비스 시작
            startService(intent)
        }
    }

    companion object {
        // 오버레이 권한 요청 코드
        private const val OVERLAY_PERMISSION_REQUEST_CODE = 1
    }
}