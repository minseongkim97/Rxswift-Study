//
//  RepositoryListCell.swift
//  RxSwift-GithubApp
//
//  Created by MIN SEONG KIM on 2022/04/17.
//

import UIKit
import SnapKit

class RepositoryListCell: UITableViewCell {
    static let identifier = "RepositoryListCell"
    var repository: Repository?
    
    let nameLabel = UILabel()
    let descriptionalLabel = UILabel()
    let starImageView = UIImageView()
    let starLabel = UILabel()
    let languageLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        [
            nameLabel, descriptionalLabel,
            starImageView, starLabel, languageLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        guard let repository = repository else { return }
        nameLabel.text = repository.name
        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        
        descriptionalLabel.text = repository.description
        descriptionalLabel.font = .systemFont(ofSize: 15)
        descriptionalLabel.numberOfLines = 2
        
        starImageView.image = UIImage(systemName: "star")
        
        starLabel.text = "\(repository.stargazersCount)"
        starLabel.font = .systemFont(ofSize: 16)
        starLabel.tintColor = .gray
        
        languageLabel.text = repository.language
        languageLabel.font = .systemFont(ofSize: 16)
        languageLabel.textColor = .gray
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(10)
        }
        
        descriptionalLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
            $0.leading.trailing.equalTo(nameLabel)
        }
        
        starImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionalLabel.snp.bottom).offset(8)
            $0.leading.equalTo(descriptionalLabel)
            $0.width.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(10)
        }
        
        starLabel.snp.makeConstraints {
            $0.centerY.equalTo(starImageView)
            $0.leading.equalTo(starImageView.snp.trailing).offset(5)
        }
        
        languageLabel.snp.makeConstraints {
            $0.centerY.equalTo(starLabel)
            $0.leading.equalTo(starLabel.snp.trailing).offset(12)
        }
    }
}

