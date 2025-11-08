//
//  LoseView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI
import SwiftData

struct LoseView: View {
    let score: Int
    let difficulty: DifficultyLevel
    let onDismiss: () -> Void
    let onStartAgain: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var bestScore: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background layers (matching Android: #66003589 - полупрозрачный фиолетовый)
                // ARGB: 66 = альфа канал (102/255 ≈ 0.4), 003589 = RGB цвет
                Color(red: 0x00/255.0, green: 0x35/255.0, blue: 0x89/255.0)
                    .opacity(0x66/255.0) // 102/255 ≈ 0.4
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                
                // Dark overlay (#33000000 - полупрозрачный черный)
                // ARGB: 33 = альфа канал (51/255 ≈ 0.2)
                Color.black
                    .opacity(0x33/255.0) // 51/255 ≈ 0.2
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .allowsHitTesting(false)
                
                // Top egg decoration (lose_egg1) - right side
                if let loseEgg1 = ResourceManager.shared.uiImage(named: .loseEgg1) {
                    Image(uiImage: loseEgg1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5)
                        .aspectRatio(482.0 / 447.0, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .allowsHitTesting(false)
                }
                
                // Lose bird (at 45% height, bottom aligned to guideline)
                let loseBirdSize = geometry.size.width * 0.7
                if let loseBird = ResourceManager.shared.uiImage(named: .loseBird) {
                    Image(uiImage: loseBird)
                        .resizable()
                        .scaledToFit()
                        .frame(width: loseBirdSize)
                        .aspectRatio(1.0, contentMode: .fit)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.45 - loseBirdSize / 2)
                        .allowsHitTesting(false)
                }
                
                // Lose frame (main container) - starts from 45% height with -40dp offset
                let frameWidth = geometry.size.width * 0.8
                let frameHeight = frameWidth * 869.0 / 955.0
                let dp40 = 40.0 * (geometry.size.height / 896.0) // Approximate dp to points conversion
                let frameTopEdge = geometry.size.height * 0.45 - dp40 // Top edge of frame
                let frameCenterY = frameTopEdge + frameHeight / 2 // Center of frame
                
                if let loseFrame = ResourceManager.shared.uiImage(named: .loseFrame) {
                    Image(uiImage: loseFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: frameWidth)
                        .aspectRatio(955.0 / 869.0, contentMode: .fit)
                        .position(x: geometry.size.width / 2, y: frameCenterY)
                        .overlay {
                            // Content inside frame - Score bottom edge at middle, BEST top edge at middle
                            GeometryReader { frameGeometry in
                                VStack(spacing: 0) {
                                    // Score and BEST centered together
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    VStack(spacing: 20) {
                                        HStack(spacing: 8) {
                                            Spacer()
                                            Spacer()
                                            Text("Score")
                                                .font(.custom("AlfaSlabOne-Regular", size: 33))
                                                .foregroundColor(.white)
                                                .shadow(color: Color(hex: "EDA40A"), radius: 5, x: 5, y: 5)
                                            
                                            Text("\(score)")
                                                .font(.custom("AlfaSlabOne-Regular", size: 33))
                                                .foregroundColor(Color(hex: "FFB800"))
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.trailing, 50)
                                        
                                        HStack(spacing: 8) {
                                            Spacer()
                                            Spacer()
                                            Text("BEST")
                                                .font(.custom("AlfaSlabOne-Regular", size: 33))
                                                .foregroundColor(.white)
                                                .shadow(color: Color(hex: "EDA40A"), radius: 5, x: 5, y: 5)
                                            
                                            Text("\(bestScore)")
                                                .font(.custom("AlfaSlabOne-Regular", size: 33))
                                                .foregroundColor(Color(hex: "FFB800"))
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.trailing, 50)
                                    }
                                    
                                    Spacer()
                                    
                                    // Buttons row at bottom
                                    HStack(spacing: 8) {
                                        // Back to menu button (left side)
                                        Button(action: onDismiss) {
                                            if let btnImage = ResourceManager.shared.uiImage(named: .backToMenu) {
                                                Image(uiImage: btnImage)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: geometry.size.width * 0.17)
                                                    .aspectRatio(199.0 / 79.0, contentMode: .fit)
                                            } else {
                                                Text("BACK TO MENU")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: geometry.size.width * 0.17)
                                                    .aspectRatio(199.0 / 79.0, contentMode: .fit)
                                                    .background(Color(hex: "1a1a2e"))
                                                    .cornerRadius(8)
                                            }
                                        }
                                        
                                        // Start again button (right side)
                                        Button(action: onStartAgain) {
                                            if let btnImage = ResourceManager.shared.uiImage(named: .startAgain) {
                                                Image(uiImage: btnImage)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: geometry.size.width * 0.17)
                                                    .aspectRatio(199.0 / 79.0, contentMode: .fit)
                                            } else {
                                                Text("START AGAIN")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: geometry.size.width * 0.17)
                                                    .aspectRatio(199.0 / 79.0, contentMode: .fit)
                                                    .background(Color(hex: "1a1a2e"))
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom, 50)
                                }
                            }
                            .frame(width: frameWidth, height: frameHeight)
                            .position(x: geometry.size.width / 2, y: frameCenterY)
                        }
                        .zIndex(10)
                }
                
                // Bottom egg decoration (lose_egg2) - left side
                if let loseEgg2 = ResourceManager.shared.uiImage(named: .loseEgg2) {
                    Image(uiImage: loseEgg2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5)
                        .aspectRatio(734.0 / 569.0, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .allowsHitTesting(false)
                }
                
                // Back button (top left) - ведет в главное меню
                VStack {
                    HStack {
                        Button(action: onDismiss) {
                            if let backImage = ResourceManager.shared.uiImage(named: .arrowBack) {
                                Image(uiImage: backImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.1)
                                    .aspectRatio(1.0, contentMode: .fit)
                            } else {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .frame(width: geometry.size.width * 0.1)
                                    .aspectRatio(1.0, contentMode: .fit)
                            }
                        }
                        .padding(.leading, 12)
                        .padding(.top, max(geometry.safeAreaInsets.top, 44) + 24)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .onAppear {
            loadBestScore()
        }
    }
    
    private func loadBestScore() {
        let descriptor = FetchDescriptor<GameResult>(
            sortBy: [SortDescriptor(\.score, order: .reverse)]
        )
        if let bestResult = try? modelContext.fetch(descriptor).first {
            bestScore = bestResult.score
        }
    }
}

#Preview {
    LoseView(score: 50, difficulty: .easy, onDismiss: {}, onStartAgain: {})
        .modelContainer(for: GameResult.self)
}
