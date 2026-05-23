package com.example.actionClinic

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class TaskWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        updateWidgets(context, manager, ids)
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, TaskWidgetProvider::class.java))
            updateWidgets(context, manager, ids)
        }

        private fun updateWidgets(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val state = WidgetStateStore.read(context)
            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                2001,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            ids.forEach { id ->
                val views = RemoteViews(context.packageName, R.layout.widget_task_small)
                views.setTextViewText(R.id.widget_title, state.title)
                views.setTextViewText(R.id.widget_subtitle, "今天 ${state.deadlineLabel} 截止")
                views.setTextViewText(R.id.widget_time, state.remainingLabel)
                views.setTextViewText(R.id.widget_status, statusLabel(state.status))
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
                manager.updateAppWidget(id, views)
            }
        }

        private fun statusLabel(status: String): String {
            return when (status) {
                "running" -> "专注中"
                "monitoring" -> "监督中"
                "completed" -> "已完成"
                "punished" -> "强提醒"
                "abandoned" -> "已放弃"
                else -> "待开始"
            }
        }
    }
}
