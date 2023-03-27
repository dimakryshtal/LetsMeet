//
//  MatchObject.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 04.03.2023.
//

import Foundation

struct MatchObject: Codable {
    let id: String
    var memberIDs: [String]
    let date: Date
}

