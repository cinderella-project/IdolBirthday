//
//  Idol.swift
//  IdolBirthdayBackend
//
//  Created by user on 2020/06/25.
//

import Foundation
import SwiftUI

public struct Idol: Decodable, Hashable {
    public var name: String
    public var birthDate: RDFBirthDate
    public var idolListURL: URL?
    public var color: EightBitColor?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.birthDate = RDFBirthDate(string: try container.decode(String.self, forKey: .birthDate))!
        if let urlString = try container.decodeIfPresent(String.self, forKey: .idolListURL) {
            self.idolListURL = URL(string: urlString)
        }
        if  let rgbString = try decoder.container(keyedBy: CodingKeys.self).decodeIfPresent(String.self, forKey: .color),
            let color = EightBitColor(hex: rgbString)
        {
            self.color = color
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case birthDate
        case idolListURL
        case color
    }
}

extension Idol: Identifiable {
    public var id: String {
        return name
    }
}
