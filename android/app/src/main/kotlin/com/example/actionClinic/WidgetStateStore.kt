package com.example.actionClinic

import android.content.Context

object WidgetStateStore {
    private const val prefsName = "clinic_widget_state"

    fun save(context: Context, args: Map<*, *>) {
        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putString("title", args["title"] as? String ?: "行动任务")
            .putString("description", args["description"] as? String ?: "现在就去行动")
            .putString("remainingLabel", args["remainingLabel"] as? String ?: "00:00")
            .putString("deadlineLabel", args["deadlineLabel"] as? String ?: "--:--")
            .putString("status", args["status"] as? String ?: "waiting")
            .apply()
    }

    fun read(context: Context): WidgetState {
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        return WidgetState(
            title = prefs.getString("title", "完成产品需求文档") ?: "完成产品需求文档",
            description = prefs.getString("description", "梳理核心需求，输出 PRD 初稿") ?: "",
            remainingLabel = prefs.getString("remainingLabel", "24:18") ?: "24:18",
            deadlineLabel = prefs.getString("deadlineLabel", "20:00") ?: "20:00",
            status = prefs.getString("status", "waiting") ?: "waiting",
        )
    }
}

data class WidgetState(
    val title: String,
    val description: String,
    val remainingLabel: String,
    val deadlineLabel: String,
    val status: String,
)
