//
//  HomeView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var musicPlayer = MusicPlayer.shared
    @StateObject private var settings = SettingsManager.shared
    @State private var showDifficulty = false
    @State private var showSettings = false
    @State private var showStatistics = false
    @State private var showPrivacy = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (centerCrop) - растягиваем на весь экран
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
                
                // Close button (top left, 10% width, square, 12dp left, 24dp top)
                VStack {
                    HStack {
                        Button(action: {
                            // Close app
                            exit(0)
                        }) {
                            if let closeImage = ResourceManager.shared.uiImage(named: .btnClose) {
                                Image(uiImage: closeImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.1)
                            }
                        }
                        .padding(.leading, 12)
                        .padding(.top, max(geometry.safeAreaInsets.top, 44) + 24)
                        
                        Spacer()
                        
                        // Privacy button (top right, 10% width, square, 12dp right, 24dp top)
                        Button(action: {
                            showPrivacy = true
                        }) {
                            if let privacyImage = ResourceManager.shared.uiImage(named: .btnPrivacy) {
                                Image(uiImage: privacyImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.1)
                            }
                        }
                        .padding(.trailing, 12)
                        .padding(.top, max(geometry.safeAreaInsets.top, 44) + 24)
                    }
                    
                    Spacer()
                }
                
                // Main content
                VStack(spacing: 0) {
                    // Отступ сверху для основного контента (учитываем статус-бар)
                    Spacer()
                        .frame(height: max(geometry.safeAreaInsets.top, 44) + 20)
                    
                    // Logo (80% width, ratio 1080:1324)
                    if let logoImage = ResourceManager.shared.uiImage(named: .logo) {
                        Image(uiImage: logoImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8)
                            .aspectRatio(1080.0 / 1324.0, contentMode: .fit)
                    }
                    
                    // Menu frame with buttons inside (54% width, ratio 694:867, -30dp margin top)
                    ZStack {
                        // Frame background
                        if let frameImage = ResourceManager.shared.uiImage(named: .mmFrame) {
                            Image(uiImage: frameImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.54)
                                .aspectRatio(694.0 / 867.0, contentMode: .fit)
                        }
                        
                        // Buttons inside frame - центрируем по вертикали
                        VStack(spacing: 8) {
                            Spacer()
                            
                            // Play button (30% width, ratio 372:147)
                            Button(action: {
                                showDifficulty = true
                            }) {
                                if let btnImage = ResourceManager.shared.uiImage(named: .btnPlay) {
                                    Image(uiImage: btnImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.3)
                                        .aspectRatio(372.0 / 147.0, contentMode: .fit)
                                } else {
                                    Text("PLAY")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 60)
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                }
                            }
                            
                            // Settings button (25% width, ratio 327:130)
                            Button(action: {
                                showSettings = true
                            }) {
                                if let btnImage = ResourceManager.shared.uiImage(named: .btnSettings) {
                                    Image(uiImage: btnImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.25)
                                        .aspectRatio(327.0 / 130.0, contentMode: .fit)
                                } else {
                                    Text("SETTINGS")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 50)
                                        .background(Color.gray)
                                        .cornerRadius(15)
                                }
                            }
                            
                            // Statistics button (25% width, ratio 327:130)
                            Button(action: {
                                showStatistics = true
                            }) {
                                if let btnImage = ResourceManager.shared.uiImage(named: .btnStatistics) {
                                    Image(uiImage: btnImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.25)
                                        .aspectRatio(327.0 / 130.0, contentMode: .fit)
                                } else {
                                    Text("STATISTICS")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 50)
                                        .background(Color.gray)
                                        .cornerRadius(15)
                                }
                            }
                            
                            // Exit button (25% width, ratio 327:130)
                            Button(action: {
                                // Exit app
                                exit(0)
                            }) {
                                if let btnImage = ResourceManager.shared.uiImage(named: .btnExit) {
                                    Image(uiImage: btnImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.25)
                                        .aspectRatio(327.0 / 130.0, contentMode: .fit)
                                } else {
                                    Text("EXIT")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 200, height: 50)
                                        .background(Color.red)
                                        .cornerRadius(15)
                                }
                            }
                            
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.54)
                        .aspectRatio(694.0 / 867.0, contentMode: .fit)
                    }
                    .offset(y: -30)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .onAppear {
            if settings.isMusicOn {
                musicPlayer.playMusic()
            }
        }
        .onChange(of: settings.isMusicOn) { oldValue, newValue in
            if newValue {
                musicPlayer.playMusic()
            } else {
                musicPlayer.stopMusic()
            }
        }
        .sheet(isPresented: $showDifficulty) {
            DifficultyView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showStatistics) {
            StatisticsView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyView(mode: .view, onAccept: {}, onBack: {
                showPrivacy = false
            })
        }
    }
}

#Preview {
    HomeView()
}
