//
//  StatisticsView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @Query(sort: \GameResult.date, order: .reverse) private var results: [GameResult]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with overlays (like Android: #66003589 and #33000000)
                if let bgImage = ResourceManager.shared.uiImage(named: .mmBg) {
                    Image(uiImage: bgImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea(.all)
                } else {
                    Color(red: 0.2, green: 0.3, blue: 0.5)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea(.all)
                }
                
                // Semi-transparent overlays
                Color(red: 0.2, green: 0.13, blue: 0.35).opacity(0.4) // #66003589
                    .ignoresSafeArea(.all)
                
                Color.black.opacity(0.1) // #33000000
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Crown image (50% width, ratio 573:623, 24dp top margin)
                    if let crownImage = ResourceManager.shared.uiImage(named: .crown) {
                        Image(uiImage: crownImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.5)
                            .aspectRatio(573.0 / 623.0, contentMode: .fit)
                            .padding(.top, max(geometry.safeAreaInsets.top, 44) + 24)
                    }
                    
                    // Frame and content
                    GeometryReader { frameGeometry in
                        let bottomPadding = 12 + max(geometry.safeAreaInsets.bottom, 0)
                        let availableHeight = frameGeometry.size.height - bottomPadding
                        
                        ZStack(alignment: .top) {
                            // Frame background (stretches to bottom with padding) - centerCrop equivalent
                            if let frameImage = ResourceManager.shared.uiImage(named: .frameStat) {
                                Image(uiImage: frameImage)
                                    .resizable()
                                    .frame(
                                        width: geometry.size.width - 24,
                                        height: max(availableHeight, 0)
                                    )
                                    .clipped()
                                    .contentShape(Rectangle())
                            }
                            
                            VStack(spacing: 0) {
                                // Statistics header text (45% width, ratio 570:108, -24dp margin top)
                                if let headerImage = ResourceManager.shared.uiImage(named: .textStatistics) {
                                    Image(uiImage: headerImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.45)
                                        .aspectRatio(570.0 / 108.0, contentMode: .fit)
                                        .offset(y: -24)
                                        .frame(maxWidth: .infinity) // Center horizontally
                                }
                                
                                // Total games text (35% width, 24dp margin top)
                                Text("GAMES \(results.count)")
                                    .font(.custom("AlfaSlabOne-Regular", size: 20))
                                    .foregroundColor(.white)
                                    .frame(width: geometry.size.width * 0.35)
                                    .padding(.top, 24)
                                    .fontWeight(.black)
                                    .frame(maxWidth: .infinity) // Center horizontally
                                
                                // Win rate text
                                HStack(spacing: 0) {
                                    Text("WINS: ")
                                        .font(.custom("AlfaSlabOne-Regular", size: 20))
                                        .foregroundColor(.white)
                                    
                                    Text(" \(winRate)%")
                                        .font(.custom("AlfaSlabOne-Regular", size: 23))
                                        .foregroundColor(Color(red: 0xED/255.0, green: 0xA4/255.0, blue: 0x0A/255.0)) // #EDA40A
                                }
                                .frame(width: geometry.size.width * 0.35, alignment: .leading)
                                .frame(maxWidth: .infinity) // Center horizontally
                                
                                // Results list (60% width) - takes remaining space
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                                            StatItemView(
                                                number: index + 1,
                                                result: result.score > 0 ? "WIN" : "LOSE",
                                                isWin: result.score > 0,
                                                screenWidth: geometry.size.width
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.top, 12)
                                }
                                .frame(width: geometry.size.width * 0.6)
                                .frame(maxWidth: .infinity) // Center horizontally
                                
                                Spacer()
                                
                                // Back button (25% width, ratio 229:90, 58dp bottom margin)
                                Button(action: {
                                    dismiss()
                                }) {
                                    if let backImage = ResourceManager.shared.uiImage(named: .btnBack) {
                                        Image(uiImage: backImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.25)
                                            .aspectRatio(229.0 / 90.0, contentMode: .fit)
                                    } else {
                                        Text("BACK")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 150, height: 50)
                                            .background(Color.blue)
                                            .cornerRadius(15)
                                    }
                                }
                                .padding(.bottom, 58)
                                .frame(maxWidth: .infinity) // Center horizontally
                            }
                            .frame(width: geometry.size.width - 24)
                            .frame(maxWidth: .infinity)
                            .frame(height: max(availableHeight, 0))
                        }
                    }
                    .offset(y: -12) // -12dp margin top as in Android
                    .padding(.bottom, 12 + max(geometry.safeAreaInsets.bottom, 0)) // 12dp margin bottom + safe area
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .presentationBackground {
            Color.clear
        }
    }
    
    private var winRate: Int {
        guard !results.isEmpty else { return 0 }
        let wins = results.filter { $0.score > 0 }.count
        return Int((Double(wins) / Double(results.count)) * 100)
    }
}

struct StatItemView: View {
    let number: Int
    let result: String
    let isWin: Bool
    let screenWidth: CGFloat
    
    var body: some View {
        HStack(spacing: 12) {
            // Number
            Text("\(number)")
                .font(.custom("AlfaSlabOne-Regular", size: 14))
                .foregroundColor(.white)
                .frame(minWidth: 24)
            
            // Level (placeholder for now - could add difficulty to GameResult)
            Text("EASY")
                .font(.custom("AlfaSlabOne-Regular", size: 13))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Result
            Text(result)
                .font(.custom("AlfaSlabOne-Regular", size: 13))
                .foregroundColor(isWin ? .green : .red)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.6))
        )
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: GameResult.self, inMemory: true)
}
