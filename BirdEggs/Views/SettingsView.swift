//
//  SettingsView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI

struct WheelHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var settings = SettingsManager.shared
    @State private var wheelHeight: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Тот же фон, что и в главном меню - растягиваем на весь экран
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
                
                // Полупрозрачный overlay (как в Android: #66003589 и #33000000)
                Color(red: 0.2, green: 0.13, blue: 0.35).opacity(0.4) // #66003589 с прозрачностью
                    .ignoresSafeArea(.all)
                
                // Dark overlay
                Color.black.opacity(0.1) // #33000000 с меньшей прозрачностью
                    .ignoresSafeArea(.all)
                
                // Settings frame with content inside - centered on screen
                VStack {
                    Spacer()
                    
                    GeometryReader { frameGeometry in
                        ZStack {
                            // Frame background
                            if let frameImage = ResourceManager.shared.uiImage(named: .settingsFrame) {
                                Image(uiImage: frameImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.8)
                                    .background(alignment: .top) {
                                        // Wheel icon - center aligned with top edge of frame
                                        if let wheelImage = ResourceManager.shared.uiImage(named: .wheel) {
                                            Image(uiImage: wheelImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: geometry.size.width * 0.65)
                                                .background(
                                                    GeometryReader { wheelGeometry in
                                                        Color.clear
                                                            .preference(key: WheelHeightKey.self, value: wheelGeometry.size.height)
                                                    }
                                                )
                                                .onPreferenceChange(WheelHeightKey.self) { height in
                                                    wheelHeight = height
                                                }
                                                .offset(y: wheelHeight > 0 ? -wheelHeight / 2 : 0) // Move up by half height so center aligns with top edge
                                        }
                                    }
                            }
                            
                            // Content inside frame - using ZStack to position button at bottom and center toggles vertically
                            ZStack(alignment: .bottom) {
                                // Toggles centered vertically
                                VStack(spacing: 0) {
                                    Spacer()
                                    
                                    // SOUND toggle
                                    SettingToggleRow(
                                        title: "SOUND",
                                        isOn: Binding(
                                            get: { settings.isSoundOn || settings.isMusicOn },
                                            set: { newValue in
                                                settings.isSoundOn = newValue
                                                settings.isMusicOn = newValue
                                            }
                                        ),
                                        screenWidth: geometry.size.width
                                    )
                                    
                                    Spacer()
                                        .frame(height: 20)
                                    
                                    // VIBRO toggle
                                    SettingToggleRow(
                                        title: "VIBRO",
                                        isOn: $settings.isVibrationOn,
                                        screenWidth: geometry.size.width
                                    )
                                    
                                    Spacer()
                                }
                                
                                // BACK button at the bottom inside frame (27% width, 52dp bottom margin as in Android)
                                Button(action: {
                                    dismiss()
                                }) {
                                    if let backImage = ResourceManager.shared.uiImage(named: .btnBack) {
                                        Image(uiImage: backImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.27)
                                            .aspectRatio(284.0 / 112.0, contentMode: .fit)
                                    } else if let backImage = ResourceManager.shared.uiImage(named: .back) {
                                        Image(uiImage: backImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.27)
                                    } else {
                                        Text("BACK")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: 150, height: 50)
                                            .background(Color.blue)
                                            .cornerRadius(15)
                                    }
                                }
                                .padding(.bottom, 52) // 52dp bottom margin as in Android
                            }
                            .frame(width: geometry.size.width * 0.65)
                            .frame(height: frameGeometry.size.height) // Match frame height
                        }
                        .frame(width: geometry.size.width * 0.8)
                        .frame(maxWidth: .infinity) // Center horizontally
                    }
                    .aspectRatio(955.0 / 869.0, contentMode: .fit) // Frame aspect ratio from Android
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .presentationBackground {
            // Прозрачный фон для sheet, чтобы видно было главное меню
            Color.clear
        }
    }
}

struct SettingToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let screenWidth: CGFloat
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
                .frame(width: 24) // Spacing between text and toggle
            
            Button(action: {
                isOn.toggle()
            }) {
                if let thumbImage = ResourceManager.shared.uiImage(named: isOn ? .thumbOn : .thumbOff) {
                    Image(uiImage: thumbImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth * 0.08)
                } else {
                    // Fallback toggle
                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .tint(.blue)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
