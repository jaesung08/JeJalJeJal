
package com.example.jejal_project

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.os.Build
import android.app.PendingIntent

class YourForegroundService : Service() {
    // 서비스가 시작될 때 호출
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = createNotification() // 알림을 생성
        startForeground(1, notification) // 생성된 알림을 포그라운드 서비스로 시작
        return START_STICKY
    }

    // 알림을 생성
    private fun createNotification(): Notification {
        val channelId = "your_channel_id"
        val channelName = "Your Channel Name"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        // Change intent to point to the OverlayLaunchActivity
        val notificationIntent = Intent(this, OverlayLaunchActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        return Notification.Builder(this, channelId)
            .setContentTitle("X-SLAYER")
            .setContentText("Overlay Enabled")
            .setSmallIcon(R.drawable.notification_icon)
            .setContentIntent(pendingIntent) // 알림을 탭했을 때 실행될 PendingIntent를 설정
            .build() // 알림을 생성하고 반환
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
