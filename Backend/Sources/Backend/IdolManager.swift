//
//  IdolsManager.swift
//  IdolBirthdayBackend
//
//  Created by user on 2020/06/24.
//

import Foundation
import SwiftSparql
import BrightFutures

public struct IdolManager {
    public static func request(q: SelectQuery) -> Future<[Idol], SwiftSparql.QueryError> {
        return Request(endpoint: URL(string: "https://sparql.crssnky.xyz/spql/imas/query")!, select: q).fetch()
    }
    
    public static func getAllIdolsQuery() -> SelectQuery {
        return SelectQuery(where: .init(patterns: subject(Var("s"))
                                            .rdfTypeIsImasIdol()
                                            .rdfsLabel(is: .init("name"))
//                                            .schemaName(is: .init("name"))
                                            .schemaBirthDate(is: .init("birthDate"))
                                            .optional { $0.imasColor(is: .init("color")) }
                                            .optional { $0.imasIdolListURL(is: .init("idolListURL")) }
                                            .triples),
                           order: [.asc(v: .init("birthDate"))])
    }
}
