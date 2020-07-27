//
//  IdolListViewController.swift
//  App iOS
//
//  Created by user on 2020/07/27.
//

import UIKit
import Backend

class IdolListViewController: UIViewController {
    enum Section {
        case one
    }
    typealias DataSource = UITableViewDiffableDataSource<Section, Idol>

    let tableView = UITableView(frame: .zero, style: .plain)
    lazy var dataSource = DataSource(tableView: tableView) { (tableView, indexPath, idol) -> UITableViewCell? in
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = idol.name
        cell.textLabel?.textColor = idol.color?.uiColor
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        cell.detailTextLabel?.text = formatter.string(from: idol.birthDate.next())
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    var idols = [Idol]() {
        didSet {
            var snapshot = dataSource.plainSnapshot()
            snapshot.appendSections([.one])
            snapshot.appendItems(idols)
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
