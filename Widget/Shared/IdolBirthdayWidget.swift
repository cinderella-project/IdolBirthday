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

func tomorrow(from today: Date, addDay: Int = 1) -> Date {
    guard let tomorrowWithHours = Calendar.current.date(byAdding: .day, value: addDay, to: today) else {
        fatalError("why??")
    }
    var tomorrow = Calendar.current.dateComponents(in: .current, from: tomorrowWithHours)
    tomorrow.hour = 0
    tomorrow.minute = 0
    tomorrow.second = 0
    tomorrow.nanosecond = 0
    return tomorrow.date!
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
    
    static func buildEntry(from idols: [Idol], configuration: ConfigurationIntent, date: Date = Date()) -> Entry {
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
        return Entry(
            date: date,
            content: .actualData(
                todayIdols: todayIdols,
                idols: comingSoonIdols,
                configuration: configuration
            )
        )
    }
    
    static func getIdols(completion: @escaping ([Idol]) -> Void) {
        IdolManager.request(q: IdolManager.getAllIdolsQuery())
            .onSuccess {
                completion($0)
            }
            .onFailure { error in
                fatalError("\(error)")
            }
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> Void) {
        Self.getIdols { idols in
            completion(Self.buildEntry(from: idols, configuration: configuration))
        }
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Self.getIdols { idols in
            var entries = [Entry]()
            let today = Date()
            for i in 0..<7 {
                let date = tomorrow(from: today, addDay: i)
                entries.append(Self.buildEntry(from: idols, configuration: configuration, date: date))
            }
            completion(.init(entries: entries, policy: .after(tomorrow(from: today))))
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMM", options: 0, locale: Locale.current)
    return formatter
}()

struct IdolView : View {
    var idol: Idol
    var showDate: Bool = true
    var date: Date
    
    var body: some View {
        HStack {
            Text(idol.name).foregroundColor(idol.color?.swiftuiColor)
            if showDate {
                Spacer()
                Text("\(idol.birthDate.next(current: date), formatter: dateFormatter)")
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
                        Text("\(entry.date, formatter: dateFormatter)")
                    }
                    ForEach(todayIdols) {
                        IdolView(idol: $0, showDate: false, date: entry.date)
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
                        Text("\(entry.date, formatter: dateFormatter)")
                    }
                }
                ForEach(idols) {
                    IdolView(idol: $0, date: entry.date)
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
