import SwiftUI
import WidgetKit

struct FocusWidget: Widget {
    let kind = "FocusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ActionWidgetProvider()) { entry in
            VStack(alignment: .leading, spacing: 8) {
                Text("专注执行中").font(.caption.bold()).foregroundStyle(.green)
                Text(entry.remainingLabel).font(.system(size: 36, weight: .black, design: .rounded))
                Text(entry.title).font(.headline).lineLimit(2)
            }
            .padding()
            .background(Color(red: 0.93, green: 1.0, blue: 0.98))
        }
        .configurationDisplayName("专注倒计时")
        .description("查看正在执行的专注任务。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
