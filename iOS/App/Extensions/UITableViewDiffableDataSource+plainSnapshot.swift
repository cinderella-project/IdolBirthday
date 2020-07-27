//
//  UITableViewDiffableDataSource+plainSnapshot.swift
//  App iOS
//
//  Created by user on 2020/07/27.
//

import UIKit

extension UITableViewDiffableDataSource {
    @inline(__always)
    func plainSnapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        return .init()
    }
}
