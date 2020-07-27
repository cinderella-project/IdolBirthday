//
//  IdolDetailView.swift
//  iOS
//
//  Created by user on 2020/07/26.
//

import SwiftUI
import Backend

struct IdolDetailView: View {
    let idol: Idol

    var body: some View {
        ScrollView {
            ZStack {
                Spacer().frame(height: 0)
                Rectangle()
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                    .aspectRatio(16/9.0, contentMode: .fit)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            List {
                HStack {
                    Text("誕生日")
                    Spacer()
                    Text("\(idol.birthDate.month)月\(idol.birthDate.day)日")
                }
            }
        }
        .navigationTitle(idol.name)
    }
}
