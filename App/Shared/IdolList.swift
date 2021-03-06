//
//  IdolList.swift
//  IdolBirthday
//
//  Created by user on 2020/07/26.
//

import SwiftUI
import Backend

struct IdolList: View {
    var idols: [Idol]
    var body: some View {
        List(idols) { idol in
            NavigationLink(destination: IdolDetailView(idol: idol)) {
                HStack {
                    Text(idol.name).foregroundColor(idol.color?.swiftuiColor)
                    Spacer()
                    Text(idol.birthDate.next(), style: .date)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct IdolList_Previews: PreviewProvider {
    static var previews: some View {
        IdolList(idols: [])
    }
}
