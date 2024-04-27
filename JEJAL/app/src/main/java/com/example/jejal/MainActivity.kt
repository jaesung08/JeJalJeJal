package com.example.jejal

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.provider.Settings
import androidx.activity.enableEdgeToEdge
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.example.jejal.R

class MainActivity : AppCompatActivity() {

    private val PHONE_STATE_PERMISSION_CODE = 101
    private lateinit var overlayPermissionRequest: ActivityResultLauncher<Intent>

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main_page)

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
}