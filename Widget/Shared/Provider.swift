//
//  Provider.swift
//  IdolBirthday
//
//  Created by user on 2020/09/23.
//

import Foundation
import WidgetKit
import Backend

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
