package com.example.jejal.call

import WebSocketClient
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.telephony.TelephonyManager
import android.util.Log
import com.example.jejal.call.CallOverlayService
import kotlinx.coroutines.*
import okio.ByteString
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import java.util.*

class CallReceiver : BroadcastReceiver() {

    private var timer: Timer? = null

    override fun onReceive(context: Context, intent: Intent) {
        // 통화 상태
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)

        //경로, 안드로이드 10 이상 대응
        val recordingsDir = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            File(context.getExternalFilesDir(null), "Recordings/Call")
        } else {
            File(Environment.getExternalStorageDirectory(), "Recordings/Call")
        }

        //웹소켓 주소
        val ws = WebSocketClient("wss://example.com/call") // 예시 WebSocketClient

        //통화 상태에 따른 처리
        when (state) {
            //전화 옴
            TelephonyManager.EXTRA_STATE_RINGING -> {
                Log.d("CallReceiver", "전화가 왔습니다.")
            }
            //전화 받음 (통화 시작)
            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                startCall(context, recordingsDir, ws)
            }
            //전화 끊음 (통화 끝)
            TelephonyManager.EXTRA_STATE_IDLE -> {
                endCall(context, ws)
            }
        }
    }

    // 통화 시작 시 실행
    private fun startCall(context: Context, recordDirectory: File, ws: WebSocketClient) {

        //팝업 띄움 (귤)
        context.startService(Intent(context, CallOverlayService::class.java).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(this)
            } else {
                context.startService(this)
            }
        })

        //타이머 가져오기
        timer = Timer()
        //6초마다 실행
        timer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                CoroutineScope(Dispatchers.IO).launch {
                    recentFile(recordDirectory)?.let {
                        Log.d("CallReceiver", "Found recording file: ${it.name}")
                        sendRecordingData(it, ws)
                    } ?: Log.d("CallReceiver", "No recording file found")
                }
            }
        }, 0, 6000)

        Log.d("CallReceiver", "전화를 받았습니다.")
    }

    //통화 끝났을 때 실행
    private fun endCall(context: Context, ws: WebSocketClient) {
        //팝업 없애기
        val overlayIntent = Intent(context, CallOverlayService::class.java)
        context.stopService(overlayIntent)
        //웹소켓 연결 끊기
        //ws.close()
        Log.d("CallReceiver", "통화를 종료했습니다.")
    }

    //파일 담아서 웹소켓으로 보내기
    private fun sendRecordingData(file: File, ws: WebSocketClient) {
        try {
            val entireBytes = Files.readAllBytes(Paths.get(file.path))
            val byteString = ByteString.of(*entireBytes) // ByteArray를 ByteString으로 변환
            //ws.send(byteString)

            //보냈다 로그에 표시
            Log.d("CallReceiver", "Sending recording data: ${file.name}, Size: ${entireBytes.size} bytes")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    //최근 파일 가져오기
    private suspend fun recentFile(recordDirectory: File): File? {
        return withContext(Dispatchers.IO) {
            recordDirectory.listFiles()?.maxByOrNull { it.lastModified() }
        }
    }

}
