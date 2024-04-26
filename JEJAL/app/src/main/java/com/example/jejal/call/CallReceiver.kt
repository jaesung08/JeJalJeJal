package com.example.jejal.call
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telephony.TelephonyManager
import android.util.Log
import com.example.jejal.call.CallOverlayService // CallOverlayService import 추가

class CallReceiver : BroadcastReceiver() {

    //    private var webSocketClient: WebSocketClient? = null
    override fun onReceive(context: Context, intent: Intent) {
        //정상 작동 체크 완료
        if (intent.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            if (state == TelephonyManager.EXTRA_STATE_RINGING) {
                Log.d("CallReceiver", "전화가 왔습니다.")
            } else if (state == TelephonyManager.EXTRA_STATE_OFFHOOK) {
                //전화를 받음

                // 통화 시작 시 CallOverlayService 시작
                val overlayIntent = Intent(context, CallOverlayService::class.java)
                if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(overlayIntent)
                } else {
                    context.startService(overlayIntent)
                }
                //웹소켓 연결 시작
//                webSocketClient = WebSocketClient("wss://example.com/call")
//                webSocketClient?.start()
                //통화녹음 데이터 전송
                //결과 수신
                Log.d("CallReceiver", "전화를 받았습니다.")
            } else if (state == TelephonyManager.EXTRA_STATE_IDLE) {
                //덜 전달된 마지막 오프셋까지 보내기

                //통화 종료 시 CallOverlayService 종료
                val overlayIntent = Intent(context, CallOverlayService::class.java)
                context.stopService(overlayIntent)

                Log.d("CallReceiver", "통화를 종료했습니다.")
//                webSocketClient?.close()

            }
        }
    }


}
