package com.example.actionClinic

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "行动提醒"
        val message = intent.getStringExtra("message") ?: "现在开始行动。"
        val requestCode = intent.getIntExtra("requestCode", 1000)
        val state = WidgetStateStore.read(context)
        val fullScreenIntent = Intent(context, StrictFocusActivity::class.java).apply {
            putExtra("title", state.title)
            putExtra("remainingLabel", state.remainingLabel)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            requestCode + 4000,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        createChannel(context)
        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .build()

        NotificationManagerCompat.from(context).notify(requestCode, notification)
        if (requestCode == 1003) {
            try {
                context.startActivity(fullScreenIntent)
            } catch (_: Exception) {
            }
        }
    }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            channelId,
            "行动治疗所强提醒",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "任务截止、宽限期和惩罚提醒"
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
        }
        context.getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    companion object {
        private const val channelId = "action_clinic_reminders"
    }
}
