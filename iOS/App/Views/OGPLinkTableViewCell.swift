//
//  OGPLinkTableViewCell.swift
//  App iOS
//
//  Created by user on 2020/07/27.
//

import UIKit
import LinkPresentation
import Combine
import Nuke

class OGPLinkTableViewCell: UITableViewCell {
    let mainImageView = UIImageView()
    let urlLabel = UILabel()
    var cancellables = Set<AnyCancellable>()
    
    init(url: URL) {
        super.init(style: .default, reuseIdentifier: nil)
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.font = .preferredFont(forTextStyle: .footnote)
        urlLabel.text = "OGP Image from \(url.absoluteString)"
        urlLabel.numberOfLines = 0
        contentView.addSubview(mainImageView)
        contentView.addSubview(urlLabel)
        NSLayoutConstraint.activate([
            mainImageView.heightAnchor.constraint(equalTo: mainImageView.widthAnchor, multiplier: 9 / 16.0),
            mainImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: urlLabel.topAnchor, constant: -8),
            mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            urlLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            urlLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            urlLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 8),
        ])
        let req = URLRequest(url: URL(string: "https://summaly-etag.vercel.app/api/v1/fetch?f=thumbnail&u=" + url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)
        URLSession.shared.dataTaskPublisher(for: req)
            .map { $0.data }
            .decode(type: OGPResult.self, decoder: JSONDecoder())
            .sink { error in
                print(error)
            } receiveValue: { ogp in
                guard let url = ogp.thumbnail else {
                    return
                }
                var req = ImageRequest(url: url)
                req.urlRequest.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:78.0) Gecko/20100101 Firefox/78.0", forHTTPHeaderField: "User-Agent")
                DispatchQueue.main.async {
                    let options = ImageLoadingOptions(transition: .fadeIn(duration: 0.1))
                    Nuke.loadImage(with: req, options: options, into: self.mainImageView)
                }
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
