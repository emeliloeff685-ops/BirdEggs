//
//  GameViewModel.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import Foundation
import SwiftData
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published var gameState = GameState()
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func setLives(_ count: Int) {
        gameState.lives = count
        gameState.maxLives = count
    }
    
    func decrementLife() {
        gameState.lives = max(0, gameState.lives - 1)
    }
    
    func addScore(_ points: Int) {
        gameState.score += points
    }
    
    func updateTime(_ seconds: Int) {
        gameState.timeLeft = seconds
    }
    
    func saveGameResult(isWin: Bool) {
        guard let context = modelContext else { return }
        let finalScore = isWin ? gameState.score : 0
        let result = GameResult(date: Date(), score: finalScore)
        context.insert(result)
        try? context.save()
    }
    
    func getBestScore() -> Int {
        guard let context = modelContext else { return 0 }
        let descriptor = FetchDescriptor<GameResult>(
            sortBy: [SortDescriptor(\.score, order: .reverse)]
        )
        if let bestResult = try? context.fetch(descriptor).first {
            return bestResult.score
        }
        return 0
    }
}
