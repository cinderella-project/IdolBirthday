//
//  ContentView.swift
//  Shared
//
//  Created by user on 2020/06/23.
//

import SwiftUI
import Backend
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

fileprivate extension View {
    func iOSOnly<T: View>(_ callback: (Self) -> T) -> some View {
        #if os(iOS)
        return callback(self)
        #else
        return self
        #endif
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel = .init()
    @State var showAboutSheet = false
    
    var body: some View {
        let content = IdolList(idols: viewModel.idols).navigationTitle("IdolBirthday")
        #if os(iOS)
            return content
                .navigationBarItems(leading: Button(action: {
                    showAboutSheet = true
                }, label: {
                    Image(systemName: "info.circle").imageScale(.large)
                }))
                .sheet(isPresented: $showAboutSheet) {
                    NavigationView {
                        AboutAppView()
                            .ignoresSafeArea()
                            .navigationTitle("About IdolBirthday")
                            .navigationBarItems(trailing: Button(action: {
                                showAboutSheet = false
                            }, label: {
                                Text("Done")
                            }))
                    }
                }
        #else
            return content
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
