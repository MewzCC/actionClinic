import SwiftUI
import WidgetKit

struct ActionWidgetView: View {
    let entry: ActionWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(statusText)
                .font(.caption.bold())
                .foregroundStyle(.green)
            Text(entry.title)
                .font(.headline.bold())
                .lineLimit(1)
            Text(entry.remainingLabel)
                .font(.system(size: 30, weight: .black, design: .rounded))
            Text("今天 \(entry.deadlineLabel) 截止")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(LinearGradient(colors: [Color(red: 0.93, green: 1.0, blue: 0.98), .white], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var statusText: String {
        switch entry.status {
        case "running": return "专注中"
        case "monitoring": return "监督中"
        case "completed": return "已完成"
        case "punished": return "强提醒"
        default: return "待开始"
        }
    }
}

struct ActionWidget: Widget {
    let kind = "ActionWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ActionWidgetProvider()) { entry in
            ActionWidgetView(entry: entry)
        }
        .configurationDisplayName("行动治疗所")
        .description("查看当前任务、剩余时间和监督状态。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct ActionClinicWidgetBundle: WidgetBundle {
    var body: some Widget {
        ActionWidget()
        FocusWidget()
        PunishmentWidget()
    }
}
