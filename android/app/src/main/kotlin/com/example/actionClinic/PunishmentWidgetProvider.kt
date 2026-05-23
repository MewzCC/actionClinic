package com.example.actionClinic

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews

class PunishmentWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        updateWidgets(context, manager, ids)
    }

    companion object {
        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, PunishmentWidgetProvider::class.java))
            updateWidgets(context, manager, ids)
        }

        private fun updateWidgets(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val state = WidgetStateStore.read(context)
            ids.forEach { id ->
                val views = RemoteViews(context.packageName, R.layout.widget_punishment_small)
                views.setTextViewText(R.id.widget_title, "拖延预警")
                views.setTextViewText(R.id.widget_subtitle, state.title)
                views.setTextViewText(R.id.widget_time, state.remainingLabel)
                manager.updateAppWidget(id, views)
            }
        }
    }
}
