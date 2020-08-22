//
//  IdolBirthdayWidget.swift
//  IdolBirthdayWidget
//
//  Created by user on 2020/06/23.
//

import WidgetKit
import SwiftUI
import Intents
import Backend


func tomorrow(from today: Date) -> Date? {
    guard let tomorrowWithHours = Calendar.current.date(byAdding: .day, value: 1, to: today) else {
        return nil
    }
    var tomorrow = Calendar.current.dateComponents(in: .current, from: tomorrowWithHours)
    tomorrow.hour = 0
    tomorrow.minute = 0
    tomorrow.second = 0
    tomorrow.nanosecond = 0
    return tomorrow.date
}

struct Provider: IntentTimelineProvider {
    typealias Intent = ConfigurationIntent
    
    struct Entry: TimelineEntry {
        enum Content {
            case placeholder
            case actualData(todayIdols: [Idol], idols: [Idol], configuration: Intent)
        }
        let date: Date
        let content: Content
    }
    
    func placeholder(in context: Context) -> Entry {
        return .init(date: Date(), content: .placeholder)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> Void) {
        IdolManager.request(q: IdolManager.getAllIdolsQuery())
            .onSuccess { idols in
                let date = Date()
                var sortedIdols = idols.sorted {
                    $0.birthDate.next(current: date) < $1.birthDate.next(current: date)
                }
                var todayIdols = [Idol]()
                var comingSoonIdols = [Idol]()
                var maxIdolCount = 4
                var todayIdolsFinished = true
                while maxIdolCount > 0 {
                    let idol = sortedIdols.removeFirst()
                    maxIdolCount -= 1
                    if idol.birthDate.isBirthDay(current: date, calendar: .current) {
                        todayIdols.append(idol)
                        todayIdolsFinished = false
                    } else {
                        // 今日が誕生日のアイドルがいる場合は"coming soon..."表示が1行取るので
                        // その分を引く必要がある
                        if !todayIdolsFinished {
                            todayIdolsFinished = true
                            maxIdolCount -= 1
                        }
                        comingSoonIdols.append(idol)
                    }
                }
                let entry = Entry(
                    date: date,
                    content: .actualData(
                        todayIdols: todayIdols,
                        idols: comingSoonIdols,
                        configuration: configuration
                    )
                )
                completion(entry)
            }
            .onFailure { error in
                fatalError("\(error)")
            }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        getSnapshot(for: configuration, in: context) { info in
            if let tomorrow = tomorrow(from: info.date) {
                completion(.init(entries: [info], policy: .after(tomorrow)))
            } else {
                completion(.init(entries: [info], policy: .atEnd))
            }
        }
    }
}

struct IdolView : View {
    var idol: Idol
    var showDate: Bool = true
    
    var body: some View {
        HStack {
            Text(idol.name).foregroundColor(idol.color?.swiftuiColor)
            if showDate {
                Spacer()
                Text(String(format: "%d月%d日", idol.birthDate.month, idol.birthDate.day))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct IdolBirthdayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            switch entry.content {
            case .placeholder:
                Text("Loading...")
            case .actualData(let todayIdols, let idols, _):
                if todayIdols.count > 0 {
                    HStack {
                        Text("Happy Birthday!")
                        Spacer()
                        Text(entry.date, style: .date)
                    }
                    ForEach(todayIdols) {
                        IdolView(idol: $0, showDate: false)
                    }
                    if idols.count > 0 {
                        HStack {
                            Text("coming soon...")
                            Spacer()
                        }
                    }
                } else {
                    HStack {
                        Text("coming soon...")
                        Spacer()
                        Text(entry.date, style: .date)
                    }
                }
                ForEach(idols) {
                    IdolView(idol: $0)
                }
            }
            Text("更新から \(entry.date, style: .timer) が経過しました").frame(maxWidth: .infinity)
        }.padding(8)
    }
}

@main
struct IdolBirthdayWidget: Widget {
    private let kind: String = "IdolBirthdayWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            IdolBirthdayWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Upcoming Birthdays")
        .description("This widget shows upcoming birthdays of idols.")
    }
}
