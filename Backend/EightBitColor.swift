//
//  EightBitColor.swift
//  
//
//  Created by user on 2020/07/27.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif


public struct EightBitColor: Hashable {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    
    public init?(hex: String) {
        guard let rgb = Int(hex, radix: 16) else {
            return nil
        }
        r = UInt8(0xFF & (rgb >> 16))
        g = UInt8(0xFF & (rgb >> 8))
        b = UInt8(0xFF & (rgb))
    }
    
    #if canImport(UIKit)
    public var uiColor: UIColor {
        .init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
    #endif
    
    public var swiftuiColor: Color {
        .init(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0)
    }
}
