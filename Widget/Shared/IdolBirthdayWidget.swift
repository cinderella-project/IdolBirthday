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

struct Provider: IntentTimelineProvider {
    struct Entry: TimelineEntry {
        enum Content {
            case placeholder
            case actualData(todayIdols: [Idol], idols: [Idol], configuration: ConfigurationIntent)
        }
        public let date: Date
        public let content: Content
    }
    
    public func placeholder(with: Context) -> Entry {
        return .init(date: Date(), content: .placeholder)
    }
    
    public func snapshot(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (Entry) -> ()) {
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

    public func timeline(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        snapshot(for: configuration, with: context) { info in
            completion(.init(entries: [info], policy: .atEnd))
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
