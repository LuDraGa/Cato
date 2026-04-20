package com.cato.cato

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Native haptic engine that bypasses Flutter's MethodChannel overhead
 * for critical haptic feedback.
 *
 * Latency killers applied:
 * 1. Pre-fire: Dart side calls this BEFORE setState
 * 2. Native bypass: Direct Vibrator access, no Flutter HapticFeedback bridge
 * 3. Overdrive: High-amplitude burst at start for ERM motor spin-up
 * 4. Cancel before fire: Always cancel() before new vibration to clear queue
 */
class HapticEngine(private val context: Context) {

    companion object {
        private const val CHANNEL = "com.cato.cato/haptics"

        // Haptic types matching Dart enum order
        private const val TYPE_NONE = 0
        private const val TYPE_SELECTION = 1
        private const val TYPE_LIGHT = 2
        private const val TYPE_MEDIUM = 3
        private const val TYPE_HEAVY = 4
    }

    private val vibrator: Vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
        manager.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "fire" -> {
                    val type = call.argument<Int>("type") ?: TYPE_NONE
                    fire(type)
                    result.success(null)
                }
                "cancel" -> {
                    vibrator.cancel()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun fire(type: Int) {
        if (type == TYPE_NONE) return
        if (!vibrator.hasVibrator()) return

        // Kill any queued vibration first (Latency Killer #4)
        vibrator.cancel()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val effect = when (type) {
                TYPE_SELECTION -> {
                    // Ultra-short tick — 8ms at low amplitude
                    VibrationEffect.createOneShot(8, 50)
                }
                TYPE_LIGHT -> {
                    // Quick soft pulse — 20ms with slight overdrive start
                    // Overdrive: 5ms at 120 then 15ms at 80 (Latency Killer #3)
                    VibrationEffect.createWaveform(
                        longArrayOf(0, 5, 0, 15),
                        intArrayOf(0, 120, 0, 80),
                        -1 // no repeat
                    )
                }
                TYPE_MEDIUM -> {
                    // Solid thud — overdrive then sustain
                    // 5ms at 200 (overdrive), then 35ms at 150
                    VibrationEffect.createWaveform(
                        longArrayOf(0, 5, 0, 35),
                        intArrayOf(0, 200, 0, 150),
                        -1
                    )
                }
                TYPE_HEAVY -> {
                    // Double-pulse slam — two distinct thumps with overdrive
                    // Burst 1: 5ms overdrive + 40ms sustain, gap, Burst 2: 5ms overdrive + 40ms sustain
                    VibrationEffect.createWaveform(
                        longArrayOf(0, 5, 0, 40, 50, 5, 0, 40),
                        intArrayOf(0, 255, 0, 200, 0, 255, 0, 220),
                        -1
                    )
                }
                else -> null
            }
            effect?.let { vibrator.vibrate(it) }
        } else {
            // Fallback for older devices (pre-API 26)
            @Suppress("DEPRECATION")
            when (type) {
                TYPE_SELECTION -> vibrator.vibrate(8)
                TYPE_LIGHT -> vibrator.vibrate(20)
                TYPE_MEDIUM -> vibrator.vibrate(40)
                TYPE_HEAVY -> vibrator.vibrate(longArrayOf(0, 45, 50, 45), -1)
            }
        }
    }
}
