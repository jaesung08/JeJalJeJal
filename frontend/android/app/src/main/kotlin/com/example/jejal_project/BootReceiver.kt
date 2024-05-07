
package com.example.jejal_project

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

// 앱 부팅 완료 시 포그라운드 서비스 시작.
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.intent.action.BOOT_COMPLETED") { // 부팅이 완료됐을 때인지 확인
            val serviceIntent = Intent(context, YourForegroundService::class.java) // Foreground 서비스를 시작하기 위한 인텐트를 생성
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context?.startForegroundService(serviceIntent) // startForegroundService 호출 -> YourForegroundService 시작
            } else {
                context?.startService(serviceIntent)
            }
        }
    }
}
