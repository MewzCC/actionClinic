import WidgetKit

struct ActionWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let description: String
    let remainingLabel: String
    let deadlineLabel: String
    let status: String
}

struct ActionWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ActionWidgetEntry {
        ActionWidgetEntry(
            date: Date(),
            title: "完成产品需求文档",
            description: "梳理核心需求，输出 PRD 初稿",
            remainingLabel: "24:18",
            deadlineLabel: "20:00",
            status: "waiting"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ActionWidgetEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ActionWidgetEntry>) -> Void) {
        let entry = readEntry()
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60))))
    }

    private func readEntry() -> ActionWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.actionClinic.widget") ?? .standard
        return ActionWidgetEntry(
            date: Date(),
            title: defaults.string(forKey: "title") ?? "完成产品需求文档",
            description: defaults.string(forKey: "description") ?? "梳理核心需求，输出 PRD 初稿",
            remainingLabel: defaults.string(forKey: "remainingLabel") ?? "24:18",
            deadlineLabel: defaults.string(forKey: "deadlineLabel") ?? "20:00",
            status: defaults.string(forKey: "status") ?? "waiting"
        )
    }
}
