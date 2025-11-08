//
//  BirdEggsApp.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI
import SwiftData

@main
struct BirdEggsApp: App {
    @StateObject private var settings = SettingsManager.shared
    @State private var showLoading = true
    @State private var showPrivacy = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameResult.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLoading {
                    LoadingView()
                        .onAppear {
                            // Через 6 секунд переходим к следующему экрану (временно изменено с 1.8)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                                showLoading = false
                                if !settings.isPrivacyAccepted {
                                    showPrivacy = true
                                }
                            }
                        }
                } else if showPrivacy {
                    PrivacyView(mode: .accept, onAccept: {
                        showPrivacy = false
                    })
                } else {
                    HomeView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
