package com.example.actionClinic

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "actionClinic/android"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestNotificationPermissionIfNeeded()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            val args = call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()
            when (call.method) {
                "syncWidget" -> {
                    WidgetStateStore.save(this, args)
                    TaskWidgetProvider.updateAll(this)
                    FocusWidgetProvider.updateAll(this)
                    PunishmentWidgetProvider.updateAll(this)
                    result.success(null)
                }
                "scheduleReminders" -> {
                    WidgetStateStore.save(this, args)
                    scheduleReminders(args)
                    TaskWidgetProvider.updateAll(this)
                    result.success(null)
                }
                "cancelReminders" -> {
                    cancelReminders()
                    result.success(null)
                }
                "startStrictFocus" -> {
                    WidgetStateStore.save(this, args)
                    startStrictFocus(args)
                    result.success(null)
                }
                "stopStrictFocus" -> {
                    stopLockTaskSafely()
                    result.success(null)
                }
                "openOverlayPermission" -> {
                    openOverlayPermission()
                    result.success(null)
                }
                "pinWidget" -> {
                    val type = args["type"] as? String ?: "task"
                    result.success(requestPinWidget(type))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestPinWidget(type: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val appWidgetManager = getSystemService(AppWidgetManager::class.java)
        if (!appWidgetManager.isRequestPinAppWidgetSupported) return false

        val providerClass = when (type) {
            "focus" -> FocusWidgetProvider::class.java
            "punishment" -> PunishmentWidgetProvider::class.java
            else -> TaskWidgetProvider::class.java
        }
        val provider = ComponentName(this, providerClass)
        return appWidgetManager.requestPinAppWidget(provider, null, null)
    }

    private fun scheduleReminders(args: Map<*, *>) {
        val graceSeconds = (args["graceSeconds"] as? Number)?.toLong() ?: 300L
        val remainingSeconds = (args["remainingSeconds"] as? Number)?.toLong() ?: 1500L
        scheduleAlarm(1001, maxOf(10L, graceSeconds - 60L), "宽限预警", "还有 1 分钟宽限期，快点开始行动。")
        scheduleAlarm(1002, maxOf(10L, remainingSeconds - 300L), "截止预警", "距离截止还剩 5 分钟，再冲一下。")
        scheduleAlarm(1003, maxOf(15L, remainingSeconds), "你又拖延了！", "检测到超时未行动，已触发强提醒。")
    }

    private fun scheduleAlarm(requestCode: Int, secondsFromNow: Long, title: String, message: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, ReminderReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("message", message)
            putExtra("requestCode", requestCode)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val triggerAt = System.currentTimeMillis() + secondsFromNow * 1000L
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
            }
        } catch (_: SecurityException) {
            alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        }
    }

    private fun cancelReminders() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (requestCode in listOf(1001, 1002, 1003)) {
            val intent = Intent(this, ReminderReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }
    }

    private fun startStrictFocus(args: Map<*, *>) {
        val intent = Intent(this, StrictFocusActivity::class.java).apply {
            putExtra("title", args["title"] as? String ?: "专注任务")
            putExtra("remainingLabel", args["remainingLabel"] as? String ?: "00:00")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        startActivity(intent)
    }

    private fun stopLockTaskSafely() {
        try {
            stopLockTask()
        } catch (_: IllegalStateException) {
        }
    }

    private fun openOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) return
        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 3010)
    }
}
