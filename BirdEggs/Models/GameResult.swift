//
//  GameResult.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import Foundation
import SwiftData

@Model
final class GameResult {
    var id: UUID
    var date: Date
    var score: Int
    
    init(date: Date, score: Int) {
        self.id = UUID()
        self.date = date
        self.score = score
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

