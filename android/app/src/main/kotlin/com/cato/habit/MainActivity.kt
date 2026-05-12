package com.cato.habit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private lateinit var hapticEngine: HapticEngine

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        hapticEngine = HapticEngine(this)
        hapticEngine.register(flutterEngine)
    }
}
