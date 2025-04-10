//
//  Question.swift
//  Cosmo-iOS
//
//  Created by 변정훈 on 4/7/25.
//

import Foundation

struct Question: Identifiable, Codable, Hashable {
    var id = UUID()
    let question: String
    let choices: [String]
    let answer: Int
}
