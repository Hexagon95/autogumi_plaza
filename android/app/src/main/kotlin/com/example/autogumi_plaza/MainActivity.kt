package com.example.autogumi_plaza

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.view.WindowInsets
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
  private val CHANNEL = "wallpaper_channel"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "setWallpaper" -> {
            try {
              val bytes = call.argument<ByteArray>("bytes")
              if (bytes == null) {
                result.error("NO_BYTES", "No image bytes received", null)
                return@setMethodCallHandler
              }

              val src = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
              val wm = WallpaperManager.getInstance(applicationContext)

              // 1) Get current visible screen size (no system bars)
              val (screenW, screenH) = getCurrentScreenSize()

              // 2) Ask launcher to use exactly this size (disables parallax on many launchers)
              wm.suggestDesiredDimensions(screenW, screenH)

              // 3) Scale by WIDTH and crop from TOP (your desired behavior)
              val bmp = scaleAndTopCropByWidth(src, screenW, screenH)

              // 4) Apply (home/system wallpaper)
              if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_SYSTEM)
              } else {
                wm.setBitmap(bmp)
              }

              result.success(true)
            } catch (e: Exception) {
              result.error("ERROR", e.message, null)
            }
          }
          else -> result.notImplemented()
        }
      }
  }

  private fun scaleAndTopCropByWidth(src: Bitmap, targetW: Int, targetH: Int): Bitmap {
    val scale = targetW.toFloat() / src.width.toFloat()
    val scaledH = (src.height * scale).roundToInt()
    val scaled = Bitmap.createScaledBitmap(src, targetW, scaledH, true)
    return if (scaledH > targetH) {
      // keep top, cut bottom overflow
      Bitmap.createBitmap(scaled, 0, 0, targetW, targetH)
    } else {
      // shorter than screen: no extra fill; you could pad if you want, but request was to avoid filling
      scaled
    }
  }

  private fun getCurrentScreenSize(): Pair<Int, Int> {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      val wm = getSystemService(WindowManager::class.java)
      val metrics = wm.currentWindowMetrics
      val insets = metrics.windowInsets.getInsetsIgnoringVisibility(
        WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout()
      )
      val b = metrics.bounds
      val w = b.width() - insets.left - insets.right
      val h = b.height() - insets.top - insets.bottom
      Pair(w, h)
    } else {
      val dm = resources.displayMetrics
      // defaultDisplay is deprecated but fine for < API 30
      @Suppress("DEPRECATION")
      windowManager.defaultDisplay.getRealMetrics(dm)
      Pair(dm.widthPixels, dm.heightPixels)
    }
  }
}
