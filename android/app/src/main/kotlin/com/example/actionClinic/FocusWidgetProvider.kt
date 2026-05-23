package com.example.actionClinic

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

class FocusWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        updateWidgets(context, manager, ids)
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, FocusWidgetProvider::class.java))
            updateWidgets(context, manager, ids)
        }

        private fun updateWidgets(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val state = WidgetStateStore.read(context)
            ids.forEach { id ->
                val views = RemoteViews(context.packageName, R.layout.widget_focus_medium)
                views.setTextViewText(R.id.widget_title, state.title)
                views.setTextViewText(R.id.widget_time, state.remainingLabel)
                views.setTextViewText(R.id.widget_subtitle, "专注执行中")
                manager.updateAppWidget(id, views)
            }
        }
    }
}
