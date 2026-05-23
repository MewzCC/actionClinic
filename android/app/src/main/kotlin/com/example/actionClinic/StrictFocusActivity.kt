package com.example.actionClinic

import android.app.Activity
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

class StrictFocusActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )
        val title = intent.getStringExtra("title") ?: "专注任务"
        val remaining = intent.getStringExtra("remainingLabel") ?: "00:00"
        setContentView(buildContent(title, remaining))
        try {
            startLockTask()
        } catch (_: IllegalStateException) {
        }
    }

    private fun buildContent(title: String, remaining: String): View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(48, 48, 48, 48)
            setBackgroundColor(0xFFFFE3D7.toInt())
        }
        root.addView(TextView(this).apply {
            text = "你又拖延了！"
            textSize = 34f
            gravity = Gravity.CENTER
            setTextColor(0xFF9A2E1C.toInt())
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        })
        root.addView(TextView(this).apply {
            text = "检测到未按时行动：$title"
            textSize = 18f
            gravity = Gravity.CENTER
            setTextColor(0xFF44221A.toInt())
            setPadding(0, 28, 0, 10)
        })
        root.addView(TextView(this).apply {
            text = "剩余 $remaining"
            textSize = 26f
            gravity = Gravity.CENTER
            setTextColor(0xFFFF503F.toInt())
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(0, 0, 0, 34)
        })
        root.addView(Button(this).apply {
            text = "我马上去做"
            textSize = 20f
            setOnClickListener {
                try {
                    stopLockTask()
                } catch (_: IllegalStateException) {
                }
                finish()
            }
        })
        return root
    }

    override fun onBackPressed() {
        // 专注强提醒期间不响应返回键。系统级 Home/最近任务的完全拦截需要设备所有者或屏幕固定授权。
    }
}
