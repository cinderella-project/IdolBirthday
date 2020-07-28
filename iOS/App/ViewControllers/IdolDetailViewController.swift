//
//  IdolDetailViewController.swift
//  App iOS
//
//  Created by user on 2020/07/27.
//

import UIKit
import Backend
import SafariServices

class IdolDetailViewController: UIViewController {
    enum Section {
        case image
        case profile
        case explore
        case exploreLastBirthDay
    }
    
    enum Item: Hashable {
        case image
        case value(String, String)
        case twitterHashtag(String)
    }
    
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>

    let idol: Idol
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    lazy var dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
        let cell: UITableViewCell
        switch item {
        case .image:
            cell = OGPLinkTableViewCell(url: self.idol.idolListURL!)
        case .value(let title, let value):
            cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = value
        case .twitterHashtag(let tag):
            cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.imageView?.image = UIImage(systemName: "magnifyingglass")
            cell.textLabel?.text = "#\(tag)"
            cell.textLabel?.textColor = cell.tintColor
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    lazy var safariVC = SFSafariViewController(url: idol.idolListURL!)

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
        tableView.delegate = self
        var snapshot = dataSource.snapshot()

        snapshot.appendSections([.image])
        snapshot.appendItems([.image])

        snapshot.appendSections([.profile])
        snapshot.appendItems([.value("誕生日", "\(idol.birthDate.month)月\(idol.birthDate.day)日")])

        snapshot.appendSections([.explore])
        let idolNameForHashtag = idol.name
            .replacingAll(matching: "=", with: "") // アスラン=BBⅡ世 はイコールがハッシュタグにならないので慣用的にイコール抜きのハッシュタグが使われている
        let yearTagsPattern = ["\(idolNameForHashtag)生誕祭", "\(idolNameForHashtag)誕生祭"]
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: Date())
        snapshot.appendItems([
            .twitterHashtag("\(idol.birthDate.month)月\(idol.birthDate.day)日は\(idolNameForHashtag)の誕生日"),
        ])
        snapshot.appendItems(yearTagsPattern.map { .twitterHashtag("\($0)\(currentYear)") })
        snapshot.appendItems([
            .twitterHashtag("\(idolNameForHashtag)生誕祭"),
            .twitterHashtag("\(idolNameForHashtag)誕生祭"),
            .twitterHashtag("\(idolNameForHashtag)誕生日")
        ])
        
        snapshot.appendSections([.exploreLastBirthDay])
        snapshot.appendItems(yearTagsPattern.map { .twitterHashtag("\($0)\(currentYear-1)") })

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

extension IdolDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        switch item {
        case .image:
            return .init(identifier: nil, previewProvider: { [self] () -> UIViewController? in
                return self.safariVC
            }, actionProvider: { elements in
                print(elements)
                return UIMenu(title: "", image: nil, identifier: nil, options: [], children: elements)
            })
        case .value(_, _), .twitterHashtag(_):
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addAnimations {
            self.present(self.safariVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return false
        }
        switch item {
        case .image, .twitterHashtag(_):
            return true
        case .value(_, _):
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        switch item {
        case .image:
            let vc = SFSafariViewController(url: idol.idolListURL!)
            present(vc, animated: true, completion: nil)
        case .twitterHashtag(let tag):
            let encodedTag = tag.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
            let url = URL(string: "twitter://hashtag/\(encodedTag)")!
            UIApplication.shared.open(url, options: [:]) { result in
                guard !result else {
                    return
                }
                let url = URL(string: "https://twitter.com/hashtag/\(encodedTag)")!
                self.present(SFSafariViewController(url: url), animated: true, completion: nil)
            }
        case .value(_, _):
            return
        }
    }
}
