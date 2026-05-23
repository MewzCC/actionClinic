import SwiftUI
import WidgetKit

struct PunishmentWidget: Widget {
    let kind = "PunishmentWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ActionWidgetProvider()) { entry in
            VStack(alignment: .leading, spacing: 8) {
                Text("拖延预警").font(.headline.bold()).foregroundStyle(.red)
                Text(entry.remainingLabel).font(.system(size: 32, weight: .black, design: .rounded))
                Text(entry.title).font(.caption).lineLimit(2)
            }
            .padding()
            .background(Color(red: 1.0, green: 0.94, blue: 0.90))
        }
        .configurationDisplayName("惩罚提醒")
        .description("查看拖延惩罚倒计时。")
        .supportedFamilies([.systemSmall])
    }
}
