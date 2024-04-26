package com.example.jejal.call

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.getSystemService
import com.example.jejal.R

// CallOverlayService.kt
class CallOverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: View
    private lateinit var textOverlay: LinearLayout
    private lateinit var speechBubbleContainer: LinearLayout
    private var isTextVisible = true

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notification = createNotification()
            startForeground(1, notification)
        }
        return START_STICKY
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotification(): Notification {
        val channelId = "call_overlay_channel"
        val channelName = "Call Overlay Channel"
        val importance = NotificationManager.IMPORTANCE_DEFAULT
        val channel = NotificationChannel(channelId, channelName, importance)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)

        val builder = Notification.Builder(this, channelId)
            .setContentTitle("Call Overlay")
            .setContentText("Call Overlay is running")
            .setSmallIcon(R.drawable.ic_launcher_foreground)

        return builder.build()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()

        // 오버레이 뷰 생성
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_layout, null)
        textOverlay = overlayView.findViewById(R.id.text_overlay_container)
        speechBubbleContainer = overlayView.findViewById(R.id.speech_bubble_container)

        // 오버레이 뷰 파라미터 설정
        val params = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
            )
        } else {
            WindowManager.LayoutParams(
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
                PixelFormat.TRANSLUCENT
            )
        }
        params.gravity = Gravity.TOP or Gravity.END
        params.x = 100
        params.y = 100

        // 오버레이 뷰 추가
        windowManager.addView(overlayView, params)

        // 아이콘 클릭 리스너 설정
        val appIcon: ImageView = overlayView.findViewById(R.id.app_icon)
        appIcon.setOnClickListener {
            if (isTextVisible) {
                textOverlay.visibility = View.GONE
            } else {
                textOverlay.visibility = View.VISIBLE
            }
            isTextVisible = !isTextVisible
        }
    }



    override fun onDestroy() {
        super.onDestroy()
        // 오버레이 뷰 제거
        if (::windowManager.isInitialized && ::overlayView.isInitialized) {
            windowManager.removeView(overlayView)
        }
    }

    private fun addSpeechBubble(text: String) {
        val speechBubble = TextView(this)
        speechBubble.background = ContextCompat.getDrawable(this, R.drawable.speech_bubble)
        speechBubble.text = text
        speechBubble.setTextColor(Color.BLACK)
        speechBubble.textSize = 16f

        val layoutParams = LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.WRAP_CONTENT,
            LinearLayout.LayoutParams.WRAP_CONTENT
        )
        speechBubble.layoutParams = layoutParams

        speechBubbleContainer.addView(speechBubble)
    }



}