//
//  LoadingView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var logoScale: CGFloat = 1.0
    @State private var animationStarted = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (centerCrop) - растягиваем на весь экран
                if let bgImage = ResourceManager.shared.uiImage(named: .loadBg) {
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
                
                // Logo (load_logo) - привязан к 75% высоты экрана снизу
                // Высота: 65% от высоты экрана
                let guidelineY = geometry.size.height * 0.75
                let logoHeight = geometry.size.height * 0.65
                
                if let logoImage = ResourceManager.shared.uiImage(named: .loadLogo) {
                    // Вычисляем правильную ширину на основе aspect ratio
                    let aspectRatio = logoImage.size.width / logoImage.size.height
                    let logoWidth = logoHeight * aspectRatio
                    
                    Image(uiImage: logoImage)
                        .renderingMode(.original) // Сохраняем оригинальные цвета и прозрачность
                        .resizable()
                        .scaledToFit()
                        .frame(width: logoWidth, height: logoHeight)
                        .scaleEffect(logoScale)
                        .position(
                            x: geometry.size.width / 2,
                            y: guidelineY - logoHeight / 2
                        )
                }
                
                // Text loading (text_loading) - внизу с отступом 23dp
                // Высота: 14% от высоты экрана, aspect ratio 808:263
                let textLoadingHeight = geometry.size.height * 0.14
                let textLoadingWidth = textLoadingHeight * (808.0 / 263.0)
                let bottomMargin: CGFloat = 23.0 * (geometry.size.height / 896.0) // Конвертируем dp в точки
                
                if let textLoadingImage = ResourceManager.shared.uiImage(named: .textLoading) {
                    Image(uiImage: textLoadingImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: textLoadingWidth, height: textLoadingHeight)
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height - textLoadingHeight / 2 - bottomMargin
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .onAppear {
            // Запускаем анимацию через 309ms после появления
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.309) {
                guard !animationStarted else { return }
                animationStarted = true
                
                // Используем withAnimation для плавной анимации
                withAnimation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                ) {
                    logoScale = 1.1
                }
            }
        }
        .onDisappear {
            // Останавливаем анимацию при исчезновении
            animationStarted = false
            logoScale = 1.0
        }
    }
}

#Preview {
    LoadingView()
}

