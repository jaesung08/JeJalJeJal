package com.example.jejal

import AutoCallRecordingHelper
import AutoCallRecordingHelper.AUTO_CALL_RECORDING_SETTING_REQUEST_CODE
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.provider.Settings
import android.widget.LinearLayout
import androidx.activity.enableEdgeToEdge
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.example.jejal.R
import com.example.jejal.historylist.HistoryListActivity
import com.example.jejal.translator.TranslatorActivity

class MainActivity : AppCompatActivity() {

    private val PHONE_STATE_PERMISSION_CODE = 101
    private val READ_MEDIA_AUDIO_PERMISSION_CODE = 102
    private val READ_EXTERNAL_STORAGE_PERMISSION_CODE = 103
    private lateinit var overlayPermissionRequest: ActivityResultLauncher<Intent>

    private val autoCallRecordingSettingLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            AutoCallRecordingHelper.handleActivityResult(result.resultCode, this)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_page)

        // 통화 자동 녹음 활성화 안내 메시지 표시
        AutoCallRecordingHelper.showAutoCallRecordingMessage(this) {
            AutoCallRecordingHelper.openAutoCallRecordingSettings(this)
        }

        findViewById<LinearLayout>(R.id.gotoTranslate).setOnClickListener {
            val intent = Intent(this, HistoryListActivity::class.java)
            startActivity(intent)
        }

        findViewById<LinearLayout>(R.id.translator).setOnClickListener {
            val intent = Intent(this, TranslatorActivity::class.java)
            startActivity(intent)
        }

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main)) { v, insets ->
            val systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars())
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom)
            insets
        }

        // Set up the overlay permission request launcher
        overlayPermissionRequest = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (Settings.canDrawOverlays(this)) {
                // Permission granted, continue with showing overlay
                // You can perform actions now that require drawing over other apps
            } else {
                // Permission not granted, handle the scenario
                // Inform the user or disable functionality that requires this permission
            }
        }

        requestOverlayPermission()
        checkPhoneStatePermission()

        // 통화 자동 녹음 활성화 안내 메시지 표시
        AutoCallRecordingHelper.showAutoCallRecordingMessage(this) {
            AutoCallRecordingHelper.openAutoCallRecordingSettings(this@MainActivity)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == AUTO_CALL_RECORDING_SETTING_REQUEST_CODE) {
            AutoCallRecordingHelper.handleActivityResult(resultCode, this)
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
            overlayPermissionRequest.launch(intent)
        }
    }

    private fun checkPhoneStatePermission() {
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.READ_PHONE_STATE), PHONE_STATE_PERMISSION_CODE)
        }
    }

    private fun checkReadMediaAudioPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && ContextCompat.checkSelfPermission(
                this, android.Manifest.permission.READ_MEDIA_AUDIO
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(android.Manifest.permission.READ_MEDIA_AUDIO),
                READ_MEDIA_AUDIO_PERMISSION_CODE
            )
        }
    }

    private fun checkReadExternalStoragePermission() {
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.READ_EXTERNAL_STORAGE), READ_EXTERNAL_STORAGE_PERMISSION_CODE)
        }
    }
}