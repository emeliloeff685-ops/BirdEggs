//
//  GameState.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import Foundation

struct GameState {
    var score: Int = 0
    var lives: Int = 5
    var timeLeft: Int = 30
    var maxLives: Int = 5
}

enum DifficultyLevel: Int, CaseIterable, Identifiable {
    case easy = 1
    case medium = 2
    case hard = 3
    
    var id: Int { rawValue }
    
    var gameTime: Int {
        switch self {
        case .easy: return 30
        case .medium: return 45
        case .hard: return 60
        }
    }
    
    var lives: Int {
        switch self {
        case .easy: return 5
        case .medium: return 4
        case .hard: return 3
        }
    }
    
    var name: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
}

enum ObjectType {
    case egg
    case bomb
}

