package com.example.jejal.call

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.example.jejal.R

class CallActivity  : AppCompatActivity(){
    //전화중 녹음 보내기 관련 activity
    //전화중 팝업 띄우기 관련 activity

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_call_page)

        window.addFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL)

    }

}