package com.speakupconnect.speakup_connect

import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import android.os.Bundle
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ProgressBar
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    private var splashProgressBar: ProgressBar? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Add a native white spinner immediately after the Activity window is
        // created. This covers the entire Flutter engine startup period
        // (1-2 s in debug), which begins in super.onCreate() and ends when
        // onFlutterUiDisplayed() fires. Using onStart() was too late — Flutter
        // was nearly ready by then, so the spinner only flashed briefly.
        val decorView = window.decorView as FrameLayout
        val pb = ProgressBar(this)
        pb.isIndeterminate = true
        pb.indeterminateDrawable.colorFilter =
            PorterDuffColorFilter(0xFFFFFFFF.toInt(), PorterDuff.Mode.SRC_IN)
        val size = (48 * resources.displayMetrics.density).toInt()
        val lp = FrameLayout.LayoutParams(size, size, Gravity.CENTER)
        decorView.addView(pb, lp)
        splashProgressBar = pb
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        // Flutter has painted its first frame — remove the native spinner.
        splashProgressBar?.let {
            (window.decorView as FrameLayout).removeView(it)
            splashProgressBar = null
        }
    }
}
