//
//  IdolViewController.swift
//  App iOS
//
//  Created by user on 2020/07/27.
//

import UIKit
import Backend

class ImageCell: UITableViewCell {
    let mainImageView = UIImageView()
    
    init() {
        super.init(style: .default, reuseIdentifier: nil)
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainImageView)
        NSLayoutConstraint.activate([
            mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor, multiplier: 9 / 16.0),
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class IdolViewController: UIViewController {
    enum Section {
        case image
        case profile
    }
    
    enum Item: Hashable {
        case image
        case value(String, String)
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>

    let idol: Idol
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    lazy var dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
        let cell: UITableViewCell
        switch item {
        case .image:
            cell = ImageCell()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "TODO: ここにアイドル名鑑のOGPを置く"
            label.sizeToFit()
            cell.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            ])
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        case .value(let title, let value):
            cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = value
        }
        return cell
    }

    init(idol: Idol) {
        self.idol = idol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = idol.name
        if idol.idolListURL != nil {
            navigationItem.rightBarButtonItem = .init(
                image: UIImage(systemName: "square.and.arrow.up"), style: .plain,
                target: self, action: #selector(shareIdolInfo(_:))
            )
        }
        tableView.dataSource = dataSource
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.image])
        snapshot.appendItems([.image])
        snapshot.appendSections([.profile])
        snapshot.appendItems([.value("誕生日", "\(idol.birthDate.month)月\(idol.birthDate.day)日")])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @objc func shareIdolInfo(_ sender: UIBarButtonItem) {
        let activityVC = UIActivityViewController(activityItems: [
            idol.idolListURL!
        ], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
        present(activityVC, animated: true, completion: nil)
    }
}
