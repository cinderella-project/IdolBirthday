//
//  Widget.swift
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

