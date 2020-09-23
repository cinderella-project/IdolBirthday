//
//  WidgetView.swift
//  IdolBirthday
//
//  Created by user on 2020/09/23.
//

import Foundation
import SwiftUI
import WidgetKit
import Backend

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

#if DEBUG
struct IdolBirthdayWidget_Previews: PreviewProvider {
    static let noIdolColor = Idol(name: "アイドルカラーがない人", birthDate: RDFBirthDate(string: "--01-01")!, idolListURL: nil, color: nil)
    static let whiteIdolColor = Idol(name: "アイドルカラーが白い人", birthDate: RDFBirthDate(string: "--01-01")!, idolListURL: nil, color: EightBitColor(hex: "FFFFFF")!)
    static let blackIdolColor = Idol(name: "アイドルカラーが黒い人", birthDate: RDFBirthDate(string: "--01-01")!, idolListURL: nil, color: EightBitColor(hex: "000000")!)
    static let grayIdolColor = Idol(name: "アイドルカラーが中間の人", birthDate: RDFBirthDate(string: "--01-01")!, idolListURL: nil, color: EightBitColor(hex: "808080")!)
    
    static var previews: some View {
        IdolBirthdayWidgetEntryView(entry: .init(date: Date(), content: .placeholder))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        IdolBirthdayWidgetEntryView(entry: .init(date: Date(), content: .actualData(
                todayIdols: [
                    noIdolColor,
                    whiteIdolColor,
                    blackIdolColor,
                    grayIdolColor,
                ], idols: [
                ], configuration: .init()
            )))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        IdolBirthdayWidgetEntryView(entry: .init(date: Date(), content: .actualData(
                todayIdols: [
                    noIdolColor,
                    whiteIdolColor,
                    blackIdolColor,
                    grayIdolColor,
                ], idols: [
                ], configuration: .init()
            )))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.colorScheme, .dark)
            .background(Color.black)
        ForEach(0..<5) { i in
            IdolBirthdayWidgetEntryView(entry: .init(date: Date(), content: .actualData(
                    todayIdols: Array(repeating: noIdolColor, count: i),
                    idols: Array(repeating: noIdolColor, count: 5 - i),
                    configuration: .init()
                )))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
#endif
