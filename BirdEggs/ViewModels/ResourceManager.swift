//
//  ResourceManager.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI
import AVFoundation
import ImageIO

class ResourceManager {
    static let shared = ResourceManager()
    
    // Image names
    enum ImageName: String {
        case bird = "bird"
        case bomb = "bomb"
        case egg1 = "egg1"
        case egg2 = "egg2"
        case egg3 = "egg3"
        case gameBg = "game_bg"
        case mmBg = "mm_bg"
        case logo = "logo_mm"
        case btnPlay = "btn_play"
        case btnSettings = "btn_settings"
        case btnStatistics = "btn_statistics"
        case btnBack = "btn_back"
        case btnClose = "btn_close"
        case btnPrivacy = "btn_privacy"
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
        case victory = "victory"
        case crown = "crown"
        case lives = "lives"
        case clock = "clock"
        case frameVictory = "frame_victory"
        case loseFrame = "lose_frame"
        case winBird = "win_bird"
        case loseBird = "lose_bird"
        case winCrown = "win_crown"
        case eggRoyal = "egg_royal"
        case back = "back"
        case mmFrame = "mm_frame"
        case btnExit = "btn_exit"
        case settingsFrame = "settings_frame"
        case thumbOn = "thumb_on"
        case thumbOff = "thumb_off"
        case wheel = "wheel"
        case arrowBack = "arrow_back"
        case scoreBg = "score_bg"
        case frameStat = "frame_stat"
        case textStatistics = "text_statistics"
        case startAgain = "start_again"
        case backToMenu = "back_to_menu"
        case topFire = "top_fire"
        case topEgg = "top_egg"
        case topEgg2 = "top_egg2"
        case bottomEgg = "bottom_egg"
        case fire = "fire"
        case loseEgg1 = "lose_egg1"
        case loseEgg2 = "lose_egg2"
        case loadBg = "load_bg"
        case loadLogo = "load_logo"
        case textLoading = "text_loading"
        case buttonBg = "button_bg"
    }
    
    func image(named name: ImageName) -> Image? {
        if let uiImage = uiImage(named: name) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    func uiImage(named name: ImageName) -> UIImage? {
        // First try to load from Assets (if added to Assets.xcassets)
        // Xcode автоматически конвертирует WebP в Assets.xcassets
        if let image = UIImage(named: name.rawValue) {
            return image
        }
        
        // Try to load WebP from Bundle Resources using ImageIO (iOS 14+)
        if let webpImage = loadWebPImage(named: name.rawValue) {
            return webpImage
        }
        
        // Try PNG
        if let path = Bundle.main.path(forResource: name.rawValue, ofType: "png", inDirectory: "Resources/Images") {
            if let data = NSData(contentsOfFile: path) {
                return UIImage(data: data as Data)
            }
        }
        
        // Try direct path - PNG
        if let path = Bundle.main.path(forResource: name.rawValue, ofType: "png") {
            if let data = NSData(contentsOfFile: path) {
                return UIImage(data: data as Data)
            }
        }
        
        return nil
    }
    
    /// Загружает WebP изображение используя ImageIO framework (поддерживается с iOS 14+)
    private func loadWebPImage(named name: String) -> UIImage? {
        // Пробуем разные пути
        let paths = [
            Bundle.main.path(forResource: name, ofType: "webp", inDirectory: "Resources/Images"),
            Bundle.main.path(forResource: name, ofType: "webp")
        ]
        
        for path in paths.compactMap({ $0 }) {
            let url = URL(fileURLWithPath: path) as CFURL
            
            // Используем ImageIO для загрузки WebP
            guard let imageSource = CGImageSourceCreateWithURL(url, nil) else { continue }
            
            // Проверяем тип изображения
            if let type = CGImageSourceGetType(imageSource) {
                let typeString = type as String
                // WebP поддерживается с iOS 14+
                if typeString.contains("webp") || typeString == "public.webp" {
                    // Создаем изображение из источника
                    let options: [CFString: Any] = [
                        kCGImageSourceShouldCache: true,
                        kCGImageSourceShouldAllowFloat: false
                    ]
                    
                    if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, options as CFDictionary) {
                        return UIImage(cgImage: cgImage)
                    }
                }
            }
            
            // Fallback: пробуем обычный способ загрузки (может работать на iOS 14+)
            if let data = NSData(contentsOfFile: path) {
                if let image = UIImage(data: data as Data) {
                    return image
                }
            }
        }
        
        return nil
    }
    
    // Sound
    var musicURL: URL? {
        // Try different paths
        if let url = Bundle.main.url(forResource: "musick", withExtension: "mp3", subdirectory: "Resources/Sounds") {
            return url
        }
        return Bundle.main.url(forResource: "musick", withExtension: "mp3")
    }
}

