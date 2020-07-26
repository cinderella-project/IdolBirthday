//
//  AboutAppView.swift
//  IdolBirthday
//
//  Created by user on 2020/07/26.
//

import SwiftUI
import UIKit

struct AboutAppView: UIViewControllerRepresentable {
    typealias UIViewControllerType = AboutAppViewController

    func makeUIViewController(context: Context) -> AboutAppViewController {
        return AboutAppViewController()
    }
    
    func updateUIViewController(_ uiViewController: AboutAppViewController, context: Context) {
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
