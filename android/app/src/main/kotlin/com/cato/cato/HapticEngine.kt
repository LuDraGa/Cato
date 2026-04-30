package com.cato.cato

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Native haptic engine.
 *
 * Architecture (see execution_docs/haptic_redesign.md):
 *   Interaction intent → Pattern → Runtime tier → Native effect
 *
 * Tier resolution per pattern (cached at init):
 *   Tier 1 COMPOSITION  API ≥ 30 + areAllPrimitivesSupported(...)
 *   Tier 2 WAVEFORM     API ≥ 26 + hasAmplitudeControl()
 *   Tier 3 ONESHOT      API ≥ 26 (pattern may opt to SKIP rather than degrade)
 *   Tier 4 LEGACY       API < 26, binary vibrate(ms) only
 *
 * Pre-fire is non-negotiable (§4b rule 5): callers invoke firePattern BEFORE
 * setState / UI frame commit. Temporal dissonance kills the entire effect.
 */
class HapticEngine(private val context: Context) {

    companion object {
        private const val CHANNEL = "com.cato.cato/haptics"

        // Per-call intensity quantization (§3 of the redesign doc).
        private const val INTENSITY_SOFT = 0.7f
        private const val INTENSITY_BASE = 1.0f
        private const val INTENSITY_ACCENT = 1.3f
    }

    private val vibrator: Vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
        manager.defaultVibrator
    } else {
        @Suppress("DEPRECATION")
        context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }

    private val mainHandler = Handler(Looper.getMainLooper())

    // A pending split-tier-3 second-beat continuation. New fire / cancel clears it.
    private var pendingContinuation: Runnable? = null

    // Capabilities — probed once at init.
    private val canCompose: Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.R
    private val canWaveform: Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && hasAmplitudeControlSafe()
    private val canOneShot: Boolean = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O

    private val supportedPrimitives: Set<Primitive> = probeSupportedPrimitives()

    private val patternTiers: Map<String, Tier> =
        Patterns.all.associate { it.id to resolveTier(it) }

    private fun hasAmplitudeControlSafe(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && vibrator.hasAmplitudeControl()

    private fun probeSupportedPrimitives(): Set<Primitive> {
        if (!canCompose) return emptySet()
        val all = Primitive.values()
        val androidIds = IntArray(all.size) { i -> all[i].toAndroidId() }
        val flags = vibrator.arePrimitivesSupported(*androidIds)
        return all.filterIndexed { i, _ -> flags[i] }.toHashSet()
    }

    private fun resolveTier(pattern: Pattern): Tier {
        if (canCompose && pattern.requiredPrimitives.all { it in supportedPrimitives }) {
            return Tier.COMPOSITION
        }
        if (canWaveform) return Tier.WAVEFORM
        if (canOneShot && pattern.tier3Strategy !is Tier3Strategy.Skip) return Tier.ONESHOT
        if (!canOneShot && pattern.tier3Strategy !is Tier3Strategy.Skip) return Tier.LEGACY
        return Tier.NONE
    }

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "firePattern" -> {
                        val id = call.argument<String>("id") ?: ""
                        val intensity = call.argument<String>("intensity") ?: "base"
                        firePattern(id, intensity)
                        result.success(null)
                    }
                    "tierFor" -> {
                        val id = call.argument<String>("id") ?: ""
                        result.success(patternTiers[id]?.name ?: "NONE")
                    }
                    "cancel" -> {
                        cancel()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun cancel() {
        pendingContinuation?.let { mainHandler.removeCallbacks(it) }
        pendingContinuation = null
        vibrator.cancel()
    }

    private fun firePattern(id: String, intensityKey: String) {
        if (!vibrator.hasVibrator()) return
        val pattern = Patterns.byId[id] ?: return
        val factor = intensityFactor(intensityKey)
        val tier = patternTiers[id] ?: Tier.NONE

        cancel()

        when (tier) {
            Tier.COMPOSITION -> fireComposition(pattern, factor)
            Tier.WAVEFORM -> fireWaveform(pattern, factor)
            Tier.ONESHOT -> fireOneShot(pattern)
            Tier.LEGACY -> fireLegacyForPattern(pattern)
            Tier.NONE -> Unit
        }
    }

    private fun intensityFactor(key: String): Float = when (key) {
        "soft" -> INTENSITY_SOFT
        "accent" -> INTENSITY_ACCENT
        else -> INTENSITY_BASE
    }

    private fun fireComposition(pattern: Pattern, factor: Float) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return
        val composition = VibrationEffect.startComposition()
        for (step in pattern.composition) {
            val scaled = (step.scale * factor).coerceIn(0f, 1f)
            composition.addPrimitive(step.primitive.toAndroidId(), scaled, step.delayMs)
        }
        vibrator.vibrate(composition.compose())
    }

    private fun fireWaveform(pattern: Pattern, factor: Float) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val src = pattern.waveform
        val amplitudes = IntArray(src.amplitudes.size) { i ->
            val raw = src.amplitudes[i]
            if (raw == 0) 0 else (raw * factor).toInt().coerceIn(1, 255)
        }
        vibrator.vibrate(VibrationEffect.createWaveform(src.timings, amplitudes, -1))
    }

    private fun fireOneShot(pattern: Pattern) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        when (val s = pattern.tier3Strategy) {
            is Tier3Strategy.Skip -> Unit
            is Tier3Strategy.Single -> {
                vibrator.vibrate(VibrationEffect.createOneShot(s.durationMs, s.amplitude))
            }
            is Tier3Strategy.Split -> {
                vibrator.vibrate(VibrationEffect.createOneShot(s.firstDurationMs, s.firstAmplitude))
                val continuation = Runnable {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        vibrator.vibrate(
                            VibrationEffect.createOneShot(s.secondDurationMs, s.secondAmplitude)
                        )
                    }
                    pendingContinuation = null
                }
                pendingContinuation = continuation
                mainHandler.postDelayed(continuation, s.gapMs)
            }
        }
    }

    private fun fireLegacyForPattern(pattern: Pattern) {
        // Pre-API-26 path — binary vibrate(ms). Use first beat's duration.
        val ms = when (val s = pattern.tier3Strategy) {
            is Tier3Strategy.Skip -> return
            is Tier3Strategy.Single -> s.durationMs
            is Tier3Strategy.Split -> s.firstDurationMs
        }
        @Suppress("DEPRECATION")
        vibrator.vibrate(ms)
    }

}

// ──────────────────────────────────────────────────────────────────────────────
// Pattern data
// ──────────────────────────────────────────────────────────────────────────────

internal enum class Tier { COMPOSITION, WAVEFORM, ONESHOT, LEGACY, NONE }

/**
 * Wrapper enum so Pattern definitions can be initialized on any API level.
 * The actual Android int constant is only resolved inside SDK-gated code paths
 * (toAndroidId is only ever called when Build.VERSION.SDK_INT >= R).
 */
internal enum class Primitive {
    LOW_TICK, TICK, CLICK, THUD, QUICK_FALL, SLOW_RISE;

    fun toAndroidId(): Int = when (this) {
        LOW_TICK -> VibrationEffect.Composition.PRIMITIVE_LOW_TICK
        TICK -> VibrationEffect.Composition.PRIMITIVE_TICK
        CLICK -> VibrationEffect.Composition.PRIMITIVE_CLICK
        THUD -> VibrationEffect.Composition.PRIMITIVE_THUD
        QUICK_FALL -> VibrationEffect.Composition.PRIMITIVE_QUICK_FALL
        SLOW_RISE -> VibrationEffect.Composition.PRIMITIVE_SLOW_RISE
    }
}

internal data class CompositionStep(val primitive: Primitive, val scale: Float, val delayMs: Int)

internal data class WaveformRecipe(val timings: LongArray, val amplitudes: IntArray)

internal sealed class Tier3Strategy {
    object Skip : Tier3Strategy()
    data class Single(val durationMs: Long, val amplitude: Int) : Tier3Strategy()
    data class Split(
        val firstDurationMs: Long,
        val firstAmplitude: Int,
        val gapMs: Long,
        val secondDurationMs: Long,
        val secondAmplitude: Int,
    ) : Tier3Strategy()
}

internal data class Pattern(
    val id: String,
    val composition: List<CompositionStep>,
    val waveform: WaveformRecipe,
    val tier3Strategy: Tier3Strategy,
    val requiredPrimitives: Set<Primitive>,
)

private fun step(primitive: Primitive, scale: Float, delayMs: Int = 0) =
    CompositionStep(primitive, scale, delayMs)

internal object Patterns {

    // 1. ceramic_tap — Level 1
    private val ceramicTap = Pattern(
        id = "ceramic_tap",
        composition = listOf(step(Primitive.LOW_TICK, 0.4f)),
        waveform = WaveformRecipe(longArrayOf(4), intArrayOf(80)),
        tier3Strategy = Tier3Strategy.Single(durationMs = 6L, amplitude = 60),
        requiredPrimitives = setOf(Primitive.LOW_TICK),
    )

    // 2. glass_bead_tick — Level 1
    private val glassBeadTick = Pattern(
        id = "glass_bead_tick",
        composition = listOf(step(Primitive.TICK, 0.5f)),
        waveform = WaveformRecipe(longArrayOf(4), intArrayOf(110)),
        tier3Strategy = Tier3Strategy.Single(durationMs = 8L, amplitude = 100),
        requiredPrimitives = setOf(Primitive.TICK),
    )

    // 3. soft_paper_press — Level 2 (soft-start envelope)
    // Tier 3: skip — shape-dependent; rectangular oneshot betrays the aesthetic.
    private val softPaperPress = Pattern(
        id = "soft_paper_press",
        composition = listOf(step(Primitive.QUICK_FALL, 0.5f)),
        waveform = WaveformRecipe(
            timings = longArrayOf(5, 5, 5, 8, 5, 5, 5),
            amplitudes = intArrayOf(50, 90, 130, 130, 100, 70, 30),
        ),
        tier3Strategy = Tier3Strategy.Skip,
        requiredPrimitives = setOf(Primitive.QUICK_FALL),
    )

    // 4. ink_settle — Level 2 + 4 (two-pulse settled rhythm)
    // Tier 3: skip — single beat reads as a regular tick, losing the "settle" meaning.
    private val inkSettle = Pattern(
        id = "ink_settle",
        composition = listOf(
            step(Primitive.TICK, 0.3f),
            step(Primitive.LOW_TICK, 0.2f, delayMs = 50),
        ),
        waveform = WaveformRecipe(
            timings = longArrayOf(3, 50, 2),
            amplitudes = intArrayOf(90, 0, 40),
        ),
        tier3Strategy = Tier3Strategy.Skip,
        requiredPrimitives = setOf(Primitive.TICK, Primitive.LOW_TICK),
    )

    // 5. dial_notch — Level 1 (overdrive permitted)
    private val dialNotch = Pattern(
        id = "dial_notch",
        composition = listOf(step(Primitive.CLICK, 0.6f)),
        waveform = WaveformRecipe(longArrayOf(5), intArrayOf(180)),
        tier3Strategy = Tier3Strategy.Single(durationMs = 12L, amplitude = 180),
        requiredPrimitives = setOf(Primitive.CLICK),
    )

    // 6. two_stage_confirm — Level 4 (visual–haptic sync is the value)
    private val twoStageConfirm = Pattern(
        id = "two_stage_confirm",
        composition = listOf(
            step(Primitive.TICK, 0.3f),
            step(Primitive.THUD, 0.6f, delayMs = 70),
        ),
        waveform = WaveformRecipe(
            timings = longArrayOf(3, 70, 3, 4, 4, 4, 4),
            amplitudes = intArrayOf(90, 0, 130, 180, 140, 90, 50),
        ),
        tier3Strategy = Tier3Strategy.Split(
            firstDurationMs = 8L, firstAmplitude = 90,
            gapMs = 70L,
            secondDurationMs = 20L, secondAmplitude = 150,
        ),
        requiredPrimitives = setOf(Primitive.TICK, Primitive.THUD),
    )

    // 7. wax_seal — Level 4 (rare ceremonial weight)
    private val waxSeal = Pattern(
        id = "wax_seal",
        composition = listOf(
            step(Primitive.SLOW_RISE, 0.7f),
            step(Primitive.THUD, 0.9f),
            step(Primitive.LOW_TICK, 0.25f, delayMs = 90),
        ),
        waveform = WaveformRecipe(
            timings = longArrayOf(5, 5, 5, 5, 10, 5, 5, 5, 5, 80, 3),
            amplitudes = intArrayOf(60, 100, 140, 180, 200, 160, 120, 80, 40, 0, 50),
        ),
        tier3Strategy = Tier3Strategy.Split(
            firstDurationMs = 60L, firstAmplitude = 180,
            gapMs = 90L,
            secondDurationMs = 3L, secondAmplitude = 50,
        ),
        requiredPrimitives = setOf(Primitive.SLOW_RISE, Primitive.THUD, Primitive.LOW_TICK),
    )

    // 8. stone_stamp — Level 4 (overdrive on attack only; stepped decay replaces flat sustain)
    private val stoneStamp = Pattern(
        id = "stone_stamp",
        composition = listOf(step(Primitive.THUD, 0.95f)),
        waveform = WaveformRecipe(
            timings = longArrayOf(3, 3, 6, 6, 6, 6, 5, 5, 5),
            amplitudes = intArrayOf(180, 220, 210, 200, 185, 160, 120, 80, 40),
        ),
        tier3Strategy = Tier3Strategy.Single(durationMs = 50L, amplitude = 220),
        requiredPrimitives = setOf(Primitive.THUD),
    )

    // 9. paper_lift — Level 2
    private val paperLift = Pattern(
        id = "paper_lift",
        composition = listOf(step(Primitive.QUICK_FALL, 0.35f)),
        waveform = WaveformRecipe(
            timings = longArrayOf(2, 2, 4, 6),
            amplitudes = intArrayOf(40, 70, 30, 20),
        ),
        tier3Strategy = Tier3Strategy.Single(durationMs = 10L, amplitude = 70),
        requiredPrimitives = setOf(Primitive.QUICK_FALL),
    )

    // 10. blocked_thud — Level 1 (damped error, no echo)
    private val blockedThud = Pattern(
        id = "blocked_thud",
        composition = listOf(step(Primitive.THUD, 0.5f)),
        waveform = WaveformRecipe(
            timings = longArrayOf(4, 8, 5, 5),
            amplitudes = intArrayOf(140, 110, 70, 40),
        ),
        tier3Strategy = Tier3Strategy.Single(durationMs = 15L, amplitude = 130),
        requiredPrimitives = setOf(Primitive.THUD),
    )

    val all: List<Pattern> = listOf(
        ceramicTap, glassBeadTick, softPaperPress, inkSettle, dialNotch,
        twoStageConfirm, waxSeal, stoneStamp, paperLift, blockedThud,
    )

    val byId: Map<String, Pattern> = all.associateBy { it.id }
}
