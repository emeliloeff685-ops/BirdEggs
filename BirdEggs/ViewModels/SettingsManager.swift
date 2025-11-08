//
//  SettingsManager.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var isMusicOn: Bool {
        didSet {
            UserDefaults.standard.set(isMusicOn, forKey: "isMusicOn")
        }
    }
    
    @Published var isSoundOn: Bool {
        didSet {
            UserDefaults.standard.set(isSoundOn, forKey: "isSoundOn")
        }
    }
    
    @Published var isVibrationOn: Bool {
        didSet {
            UserDefaults.standard.set(isVibrationOn, forKey: "isVibrationOn")
        }
    }
    
    @Published var isPrivacyAccepted: Bool {
        didSet {
            UserDefaults.standard.set(isPrivacyAccepted, forKey: "isPrivacyAccepted")
        }
    }
    
    private init() {
        self.isMusicOn = UserDefaults.standard.bool(forKey: "isMusicOn")
        self.isSoundOn = UserDefaults.standard.bool(forKey: "isSoundOn")
        self.isVibrationOn = UserDefaults.standard.bool(forKey: "isVibrationOn")
        self.isPrivacyAccepted = UserDefaults.standard.bool(forKey: "isPrivacyAccepted")
    }
}

