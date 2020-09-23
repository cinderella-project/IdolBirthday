//
//  IdolView.swift
//  IdolBirthday
//
//  Created by user on 2020/09/23.
//

import Foundation
import SwiftUI
import Backend

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
