//
//  Repository.swift
//  RxSwift-GithubApp
//
//  Created by MIN SEONG KIM on 2022/04/17.
//

import Foundation

struct Repository: Codable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case stargazersCount = "stargazers_count"
    }
}
