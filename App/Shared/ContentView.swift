//
//  ContentView.swift
//  Shared
//
//  Created by user on 2020/06/23.
//

import SwiftUI
import IdolBirthdayBackend
import Combine

final class ContentViewModel: ObservableObject, Identifiable {
    @Published var idols: [Idol] = []
    
    init() {
        let req = IdolManager.request(q: IdolManager.getAllIdolsQuery()).andThen { result in
            switch result {
            case .success(let idols):
                let idols = idols.sorted { $0.birthDate.next() < $1.birthDate.next() }
                print(idols)
                self.idols = idols
            case .failure(let error):
                print(error)
            }
        }
        print(req)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel = .init()
    
    var body: some View {
        List(viewModel.idols) { idol in
            HStack {
                Text(idol.name).foregroundColor(idol.color)
                Spacer()
                Text(idol.birthDate.next(), style: .date)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
