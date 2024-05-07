
package com.example.jejal_project

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle

class YourOverlayActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val engine = flutterEngine
        engine?.dartExecutor?.executeDartEntrypoint(
            io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint.createDefault()
        )
    }
}
