//
//  WinView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI
import SwiftData

struct WinView: View {
    let score: Int
    let stars: Int
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
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea(.all)
                
                // Dark overlay (#33000000 - полупрозрачный черный)
                // ARGB: 33 = альфа канал (51/255 ≈ 0.2)
                Color.black
                    .opacity(0x33/255.0) // 51/255 ≈ 0.2
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea(.all)
                    .allowsHitTesting(false)
                
                // Top fire decoration
                if let topFire = ResourceManager.shared.uiImage(named: .topFire) {
                    Image(uiImage: topFire)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                        .aspectRatio(1080.0 / 625.0, contentMode: .fit)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .allowsHitTesting(false)
                }
                
                // Top egg decoration (right side)
                if let topEgg = ResourceManager.shared.uiImage(named: .topEgg) {
                    Image(uiImage: topEgg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.7)
                        .aspectRatio(790.0 / 626.0, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .allowsHitTesting(false)
                }
                
                // Top egg2 decoration (left side, above crown)
                if let topEgg2 = ResourceManager.shared.uiImage(named: .topEgg2) {
                    let crownHeight = geometry.size.width * 0.6 * 513.0 / 717.0
                    Image(uiImage: topEgg2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.2)
                        .aspectRatio(263.0 / 361.0, contentMode: .fit)
                        .position(
                            x: geometry.size.width * 0.1,
                            y: geometry.size.height * 0.45 - crownHeight / 2 - geometry.size.width * 0.2 * 361.0 / 263.0 / 2
                        )
                        .allowsHitTesting(false)
                }
                
                // Crown (at 45% height, bottom aligned to guideline)
                let crownHeight = geometry.size.width * 0.6 * 513.0 / 717.0
                if let crown = ResourceManager.shared.uiImage(named: .winCrown) {
                    Image(uiImage: crown)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.6)
                        .aspectRatio(717.0 / 513.0, contentMode: .fit)
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.45 - crownHeight / 2)
                        .allowsHitTesting(false)
                }
                
                // Win frame (main container) - starts from 45% height with -40dp offset
                let frameWidth = geometry.size.width * 0.8
                let frameHeight = frameWidth * 869.0 / 955.0
                let dp40 = 40.0 * (geometry.size.height / 896.0) // Approximate dp to points conversion
                let frameTopEdge = geometry.size.height * 0.45 - dp40 // Top edge of frame
                let frameCenterY = frameTopEdge + frameHeight / 2 // Center of frame
                
                if let winFrame = ResourceManager.shared.uiImage(named: .frameVictory) {
                    Image(uiImage: winFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: frameWidth)
                        .aspectRatio(955.0 / 869.0, contentMode: .fit)
                        .position(x: geometry.size.width / 2, y: frameCenterY)
                        .overlay {
                            // Content inside frame - Score and BEST centered
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
                
                // Bottom fire decoration (below winFrame with -80dp offset)
                if let fire = ResourceManager.shared.uiImage(named: .fire) {
                    let dp80 = 80.0 * (geometry.size.height / 896.0)
                    let fireTopY = frameTopEdge + frameHeight - dp80
                    let fireHeight = geometry.size.height - fireTopY
                    
                    Image(uiImage: fire)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: fireHeight)
                        .position(
                            x: geometry.size.width / 2,
                            y: fireTopY + fireHeight / 2
                        )
                        .allowsHitTesting(false)
                }
                
                // Bottom egg decoration (right side, aligned to bottom of winFrame)
                if let bottomEgg = ResourceManager.shared.uiImage(named: .bottomEgg) {
                    Image(uiImage: bottomEgg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.4)
                        .aspectRatio(385.0 / 481.0, contentMode: .fit)
                        .position(
                            x: geometry.size.width * 0.8,
                            y: frameTopEdge + frameHeight
                        )
                        .allowsHitTesting(false)
                }
                
                // Win bird at bottom left
                if let winBird = ResourceManager.shared.uiImage(named: .winBird) {
                    Image(uiImage: winBird)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.5)
                        .aspectRatio(749.0 / 698.0, contentMode: .fit)
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
        }
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    WinView(score: 56, stars: 3, onDismiss: {}, onStartAgain: {})
        .modelContainer(for: GameResult.self)
}
