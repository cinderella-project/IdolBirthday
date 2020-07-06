//
//  Idol.swift
//  IdolBirthdayBackend
//
//  Created by user on 2020/06/25.
//

import Foundation
import SwiftUI

public struct Idol: Decodable {
    public var name: String
    public var birthDate: RDFBirthDate
    public var color: Color?
    
    public init(from decoder: Decoder) throws {
        self.name = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .name)
        self.birthDate = RDFBirthDate(string: try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .birthDate))!
        if  let rgbString = try decoder.container(keyedBy: CodingKeys.self).decodeIfPresent(String.self, forKey: .color),
            let rgb = Int(rgbString, radix: 16)
        {
            let r = 0xFF & (rgb >> 16)
            let g = 0xFF & (rgb >> 8)
            let b = 0xFF & (rgb)
            color = .init(red: Double(r) / 255.0, green: Double(g) / 255.0, blue: Double(b) / 255.0)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case birthDate
        case color
    }
}

extension Idol: Identifiable {
    public var id: String {
        return name
    }
}
