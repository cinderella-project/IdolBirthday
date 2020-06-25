//
//  IdolBirthdayWidget.swift
//  IdolBirthdayWidget
//
//  Created by user on 2020/06/23.
//

import WidgetKit
import SwiftUI
import Intents
import IdolBirthdayBackend

struct Provider: IntentTimelineProvider {
    public func snapshot(for configuration: ConfigurationIntent, with context: Context, completion: @escaping (IdolBirthdaysInfo) -> ()) {
        IdolManager.request(q: IdolManager.getAllIdolsQuery())
            .onSuccess { idols in
                let date = Date()
                let idols = idols.sorted { $0.birthDate.next(current: date) < $1.birthDate.next(current: date) }
                let entry = IdolBirthdaysInfo(date: date, idols: idols, configuration: configuration)
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

struct IdolBirthdaysInfo: TimelineEntry {
    public let date: Date
    public let idols: [Idol]
    public let configuration: ConfigurationIntent
}

struct PlaceholderView : View {
    var body: some View {
        Text("Loading...")
    }
}

struct IdolBirthdayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            HStack {
                Text("Happy Birthday!")
                Spacer()
                Text(entry.date, style: .date)
            }
            ForEach(entry.idols[0..<3]) { idol in
                HStack {
                    Text(idol.name).foregroundColor(idol.color)
                    Spacer()
                    Text(String(format: "%02d月%02d日", idol.birthDate.month, idol.birthDate.day))
                        .foregroundColor(.secondary)
                }
            }
        }.padding(8)
    }
}

@main
struct IdolBirthdayWidget: Widget {
    private let kind: String = "IdolBirthdayWidget"

    public var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider(), placeholder: PlaceholderView()) { entry in
            IdolBirthdayWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
