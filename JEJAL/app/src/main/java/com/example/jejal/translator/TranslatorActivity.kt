package com.example.jejal.translator

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaRecorder
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import android.widget.Button
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.jejal.R
import java.io.IOException

class TranslatorActivity : AppCompatActivity() {
    private var mediaRecorder: MediaRecorder? = null
    private var audioFilePath: String? = null

    companion object {
        const val MY_PERMISSIONS_RECORD_AUDIO = 1
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_translator_page)

        val startButton: Button = findViewById(R.id.startButton)
        val stopButton: Button = findViewById(R.id.stopButton)
        stopButton.isEnabled = false

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), MY_PERMISSIONS_RECORD_AUDIO)
        }

        startButton.setOnClickListener {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
                startRecording()
                stopButton.isEnabled = true
                startButton.isEnabled = false
            } else {
                Toast.makeText(this, "Record permission is necessary", Toast.LENGTH_SHORT).show()
            }
        }

        stopButton.setOnClickListener {
            stopRecording()
            stopButton.isEnabled = false
            startButton.isEnabled = true
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == MY_PERMISSIONS_RECORD_AUDIO) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Permission granted!", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Permission denied! Cannot record audio.", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun startRecording() {
        val recordingFilename = "recording_${System.currentTimeMillis()}.m4a"
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, recordingFilename)
            put(MediaStore.MediaColumns.MIME_TYPE, "audio/mp4")
            put(MediaStore.Audio.Media.RELATIVE_PATH, "Music/Recordings")
        }

        val resolver = applicationContext.contentResolver
        val uri = resolver.insert(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, contentValues)

        if (uri != null) {
            mediaRecorder = MediaRecorder().apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setOutputFile(resolver.openFileDescriptor(uri, "w")?.fileDescriptor)
                prepare()
                start()
            }
            audioFilePath = uri.toString()
        } else {
            Toast.makeText(this@TranslatorActivity, "Failed to create file", Toast.LENGTH_SHORT).show()
        }
    }


    private fun stopRecording() {
        mediaRecorder?.apply {
            stop()
            release()
        }
        mediaRecorder = null
        Toast.makeText(this, "Recording saved to: $audioFilePath", Toast.LENGTH_LONG).show()
        Log.d("AudioPath", "File URI: $audioFilePath")
    }

    override fun onDestroy() {
        super.onDestroy()
        mediaRecorder?.release()
        mediaRecorder = null
    }
}
