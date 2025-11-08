//
//  DifficultyView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI

struct DifficultyView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedDifficulty: DifficultyLevel?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Тот же фон, что и в главном меню
                if let bgImage = ResourceManager.shared.uiImage(named: .mmBg) {
                    Image(uiImage: bgImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    Color(red: 0.2, green: 0.3, blue: 0.5)
                        .ignoresSafeArea()
                }
                
                // Полупрозрачный overlay (как в Android: #66003589 и #33000000)
                Color(red: 0.2, green: 0.13, blue: 0.35).opacity(0.4) // #66003589 с прозрачностью
                    .ignoresSafeArea()
                
                // Dark overlay
                Color.black.opacity(0.1) // #33000000 с меньшей прозрачностью
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top egg image
                    if let eggImage = ResourceManager.shared.uiImage(named: .eggRoyal) {
                        Image(uiImage: eggImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.65)
                            .padding(.top, 24)
                    }
                    
                    Spacer()
                        .frame(height: 0)
                    
                    // Easy button
                    DifficultyButtonView(
                        imageName: .easy,
                        difficulty: .easy,
                        screenWidth: geometry.size.width
                    ) {
                        selectedDifficulty = .easy
                    }
                    
                    Spacer()
                        .frame(height: 12)
                    
                    // Medium button
                    DifficultyButtonView(
                        imageName: .medium,
                        difficulty: .medium,
                        screenWidth: geometry.size.width
                    ) {
                        selectedDifficulty = .medium
                    }
                    
                    Spacer()
                        .frame(height: 12)
                    
                    // Hard button
                    DifficultyButtonView(
                        imageName: .hard,
                        difficulty: .hard,
                        screenWidth: geometry.size.width
                    ) {
                        selectedDifficulty = .hard
                    }
                    
                    Spacer()
                        .frame(height: 12)
                    
                    // Back button
                    Button(action: {
                        dismiss()
                    }) {
                        if let backImage = ResourceManager.shared.uiImage(named: .back) {
                            Image(uiImage: backImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.3)
                        } else {
                            Text("BACK")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 150, height: 50)
                                .background(Color.gray)
                                .cornerRadius(15)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .frame(width: geometry.size.width)
            }
        }
        .presentationBackground {
            // Прозрачный фон для sheet, чтобы видно было главное меню
            Color.clear
        }
        .fullScreenCover(item: $selectedDifficulty) { difficulty in
            GameView(difficulty: difficulty)
        }
    }
}

struct DifficultyButtonView: View {
    let imageName: ResourceManager.ImageName
    let difficulty: DifficultyLevel
    let screenWidth: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                if let buttonImage = ResourceManager.shared.uiImage(named: imageName) {
                    Image(uiImage: buttonImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.5)
                } else {
                    // Fallback
                    VStack(spacing: 8) {
                        Text(difficulty.name.uppercased())
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(difficulty.gameTime) seconds, \(difficulty.lives) lives")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: min(250, screenWidth * 0.7), height: 80)
                    .background(difficultyColor)
                    .cornerRadius(15)
                }
                Spacer()
            }
        }
    }
    
    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

#Preview {
    DifficultyView()
}

