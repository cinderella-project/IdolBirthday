//
//  IdolListViewController.swift
//  App iOS
//
//  Created by user on 2020/07/27.
//

import UIKit
import Backend
import WidgetKit

class IdolListViewController: UIViewController {
    class DataSource: UITableViewDiffableDataSource<RDFBirthDate, Idol> {
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            let section = snapshot().sectionIdentifiers[section]
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: section.next())
        }
    }

    let tableView = UITableView(frame: .zero, style: .plain)
    lazy var dataSource = DataSource(tableView: tableView) { (tableView, indexPath, idol) -> UITableViewCell? in
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = idol.name
        cell.textLabel?.textColor = idol.color?.uiColor
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    var idols = [Idol]() {
        didSet {
            var snapshot = dataSource.plainSnapshot()
            var lastBirthDate: RDFBirthDate!
            for idol in idols {
                if lastBirthDate != idol.birthDate {
                    lastBirthDate = idol.birthDate
                    snapshot.appendSections([lastBirthDate])
                }
                snapshot.appendItems([idol])
            }
            dataSource.apply(snapshot)
        }
    }
    
    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "IdolBirthday"
        navigationItem.leftBarButtonItem = .init(
            image: UIImage(systemName: "info.circle"), style: .plain,
            target: self, action: #selector(openAboutVC)
        )
        tableView.dataSource = dataSource
        tableView.delegate = self
        dataSource.defaultRowAnimation = .top
        loadIdols()
    }
    
    func loadIdols() {
        IdolManager.request(q: IdolManager.getAllIdolsQuery())
            .onSuccess { idols in
                let idols = idols.sorted { $0.birthDate.next() < $1.birthDate.next() }
                self.idols = idols
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onFailure { error in
                let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                alert.addAction(.init(title: "Dismiss", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    @objc func openAboutVC() {
        let vc = AboutAppViewController()
        showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: false)
        }
    }
}

extension IdolListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let vc = IdolDetailViewController(idol: item)
        showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
    }
}
