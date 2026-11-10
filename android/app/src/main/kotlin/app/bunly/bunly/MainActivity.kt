package app.bunly.bunly

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.speech.RecognizerIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val SPEECH_CHANNEL = "app.bunly.bunly/speech"
        private const val SPEECH_REQUEST_CODE = 4201
    }

    private var pendingSpeechResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SPEECH_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "listenJapanese" -> {
                        if (pendingSpeechResult != null) {
                            result.error(
                                "speech_busy",
                                "Đang có phiên thu âm giọng nói khác diễn ra.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        val locale = call.argument<String>("locale") ?: "ja-JP"
                        val prompt = call.argument<String>("prompt")
                            ?: "Hãy đọc câu tiếng Nhật (ví dụ: 日本へ行ったことがあります)..."
                        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                            putExtra(
                                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM,
                            )
                            putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                            putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, locale)
                            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
                            putExtra(RecognizerIntent.EXTRA_PROMPT, prompt)
                        }
                        try {
                            pendingSpeechResult = result
                            @Suppress("DEPRECATION")
                            startActivityForResult(intent, SPEECH_REQUEST_CODE)
                        } catch (_: ActivityNotFoundException) {
                            pendingSpeechResult = null
                            result.error(
                                "speech_unavailable",
                                "Thiết bị chưa bật dịch vụ nhận diện giọng nói của Google.",
                                null,
                            )
                        } catch (e: Exception) {
                            pendingSpeechResult = null
                            result.error(
                                "speech_failed",
                                e.localizedMessage ?: "Không thể khởi động nhận diện giọng nói.",
                                null,
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != SPEECH_REQUEST_CODE) return
        val callback = pendingSpeechResult ?: return
        pendingSpeechResult = null

        if (resultCode == Activity.RESULT_OK && data != null) {
            val matches = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS) ?: arrayListOf()
            val scores = data.getFloatArrayExtra(RecognizerIntent.EXTRA_CONFIDENCE_SCORES)
            val primaryConf = if (scores != null && scores.isNotEmpty() && scores[0] >= 0f) {
                scores[0].toDouble()
            } else {
                null
            }
            callback.success(
                mapOf(
                    "status" to "ok",
                    "text" to (matches.firstOrNull() ?: ""),
                    "alternatives" to matches.toList(),
                    "confidence" to primaryConf,
                ),
            )
        } else {
            callback.success(
                mapOf(
                    "status" to "cancelled",
                ),
            )
        }
    }
}
