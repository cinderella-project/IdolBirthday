//
//  AboutAppViewController.swift
//  iOS
//
//  Created by user on 2020/07/26.
//

import UIKit
import SafariServices

class AboutAppViewController: UIViewController {
    class DataSource: UITableViewDiffableDataSource<Section, Item> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            switch self.snapshot().sectionIdentifiers[section] {
            case .dataProvider:
                return "データ取得元"
            case .top:
                return nil
            }
        }
    }
    
    enum Section {
        case top
        case dataProvider
    }
    
    enum Item: Hashable {
        case app(String, String)
        case link(String, URL)
    }
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    lazy var dataSource = DataSource(tableView: tableView) { (tableView, indexPath, item) -> UITableViewCell? in
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        switch item {
        case .link(let title, let url):
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = url.absoluteString
            cell.accessoryType = .disclosureIndicator
        case .app(let version, let buildNumber):
            cell.textLabel?.text = "IdolBirthday"
            cell.detailTextLabel?.text = "Version \(version) (\(buildNumber))"
        }
        return cell
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "About IdolBirthday"
        tableView.dataSource = dataSource
        tableView.delegate = self
        var snapshot = dataSource.snapshot()
        if let infoDic = Bundle.main.infoDictionary {
            snapshot.appendSections([.top])
            snapshot.appendItems([.app(infoDic["CFBundleShortVersionString"] as! String, infoDic["CFBundleVersion"] as! String)])
        }
        snapshot.appendSections([.dataProvider])
        snapshot.appendItems([.link("im@sparql (アイドルのデータ)", URL(string: "https://sparql.crssnky.xyz/imas/")!)])
        // todo
        dataSource.apply(snapshot)
    }
}

extension AboutAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case .app:
            return
        case .link(_, let url):
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return false
        }
        return cell.accessoryType == .disclosureIndicator
    }
}
