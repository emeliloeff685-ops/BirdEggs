//
//  GameView.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import SwiftUI
import SwiftData

struct HUDHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var settings = SettingsManager.shared
    
    let difficulty: DifficultyLevel
    
    @State private var gameTime: Int = 30
    @State private var lives: Int = 5
    @State private var score: Int = 0
    @State private var isGameActive = false
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    @State private var fallingObjects: [FallingObject] = []
    @State private var birdPosition: CGPoint = .zero
    @State private var birdScaleX: CGFloat = 1.0
    @State private var showWinScreen = false
    @State private var showLoseScreen = false
    @State private var finalScore = 0
    @State private var stars = 0
    @State private var objectTimers: [UUID: Timer] = [:]
    @State private var screenSize: CGSize = .zero
    @State private var hudHeight: CGFloat = 0
    @State private var restartGame = false
    
    // Game constants (from Android)
    private let spawnInterval: TimeInterval = 1.07 // Увеличено в 2 раза (было 0.535)
    private let fallDuration: TimeInterval = 3.0
    private let birdMoveDuration: TimeInterval = 0.2
    private let pointsPerEgg = 10
    private let rotationMin: Double = -45
    private let rotationMax: Double = 45
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (centerCrop) - растягиваем на весь экран
                if let bgImage = ResourceManager.shared.uiImage(named: .gameBg) {
                    Image(uiImage: bgImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .ignoresSafeArea(.all)
                } else {
                    Color(red: 0.1, green: 0.2, blue: 0.4)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea(.all)
                }
                
                VStack(spacing: 0) {
                    // HUD - matching Android layout
                    VStack(spacing: 0) {
                        // Back button (top left, 10% width, square, 12dp left, 24dp top)
                        HStack {
                            Button(action: {
                                endGame()
                                dismiss()
                            }) {
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
                        
                        // Score background (35% width, ratio 468:185, 12dp margin top)
                        if let scoreBgImage = ResourceManager.shared.uiImage(named: .scoreBg) {
                            ZStack {
                                Image(uiImage: scoreBgImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.35)
                                    .aspectRatio(468.0 / 185.0, contentMode: .fit)
                                
                                // Score text inside score_bg
                                Text("\(score)")
                                    .font(.custom("AlfaSlabOne-Regular", size: 22))
                                    .foregroundColor(.white)
                                    .shadow(color: Color(red: 0.93, green: 0.64, blue: 0.04), radius: 5, x: 5, y: 5)
                            }
                            .padding(.top, 12)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            hudHeight = geo.size.height + max(geometry.safeAreaInsets.top, 44) + 24 + 12
                                        }
                            })
                        } else {
                            // Fallback score display
                            Text("\(score)")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(10)
                                .padding(.top, max(geometry.safeAreaInsets.top, 44) + 24 + 12)
                        }
                        
                        // Lives, Clock, Timer row (under score_bg)
                        HStack(spacing: 6) {
                            // Lives icon
                            if let livesImage = ResourceManager.shared.uiImage(named: .lives) {
                                Image(uiImage: livesImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height * 0.04)
                                    .aspectRatio(10.0 / 9.0, contentMode: .fit)
                            } else {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                            }
                            
                            // Lives text
                            Text("\(lives)")
                                .font(.custom("AlfaSlabOne-Regular", size: 20))
                                .foregroundColor(.white)
                                .shadow(color: Color(red: 0.93, green: 0.64, blue: 0.04), radius: 5, x: 5, y: 5)
                            
                            // Clock icon
                            if let clockImage = ResourceManager.shared.uiImage(named: .clock) {
                                Image(uiImage: clockImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: geometry.size.height * 0.04)
                                    .aspectRatio(82.0 / 96.0, contentMode: .fit)
                            } else {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                            
                            // Timer text
                            Text(formatTime(gameTime))
                                .font(.custom("AlfaSlabOne-Regular", size: 20))
                                .foregroundColor(.white)
                                .shadow(color: Color(red: 0.93, green: 0.64, blue: 0.04), radius: 5, x: 5, y: 5)
                        }
                        .padding(.leading, 6)
                        .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        GeometryReader { hudGeo in
                            Color.clear
                                .preference(key: HUDHeightKey.self, value: hudGeo.size.height)
                        }
                    )
                    .onPreferenceChange(HUDHeightKey.self) { height in
                        DispatchQueue.main.async {
                            hudHeight = height
                        }
                    }
                    
                    Spacer()
                    
                    // Game area with falling objects and bird
                    GeometryReader { gameGeometry in
                        ZStack {
                            // Falling objects
                            ForEach(fallingObjects) { obj in
                                obj.view
                                    .position(obj.position)
                            }
                            
                            // Bird (25% width, ratio 454:682, bottom of screen)
                            if let birdImage = ResourceManager.shared.uiImage(named: .bird) {
                                Image(uiImage: birdImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.25)
                                    .aspectRatio(454.0 / 682.0, contentMode: .fit)
                                    .scaleEffect(x: birdScaleX, y: 1.0)
                                    .position(birdPosition)
                            } else {
                                Image(systemName: "bird.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.yellow)
                                    .scaleEffect(x: birdScaleX, y: 1.0)
                                    .position(birdPosition)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if isGameActive {
                                        let targetX = value.location.x
                                        let birdWidth = geometry.size.width * 0.25
                                        let clampedX = min(max(targetX, birdWidth / 2), geometry.size.width - birdWidth / 2)
                                        
                                        // Determine bird direction
                                        if clampedX > birdPosition.x {
                                            birdScaleX = 1.0
                                        } else if clampedX < birdPosition.x {
                                            birdScaleX = -1.0
                                        }
                                        
                                        // Animate bird movement
                                        withAnimation(.easeOut(duration: birdMoveDuration)) {
                                            birdPosition.x = clampedX
                                        }
                                    }
                                }
                        )
                        .onAppear {
                            let birdWidth = geometry.size.width * 0.25
                            let birdHeight = birdWidth * 682.0 / 454.0
                            birdPosition = CGPoint(
                                x: geometry.size.width / 2,
                                y: gameGeometry.size.height - birdHeight / 2
                            )
                            screenSize = geometry.size
                        }
                        .onChange(of: gameGeometry.size) { newSize in
                            screenSize = geometry.size
                            let birdWidth = geometry.size.width * 0.25
                            let birdHeight = birdWidth * 682.0 / 454.0
                            birdPosition = CGPoint(
                                x: geometry.size.width / 2,
                                y: newSize.height - birdHeight / 2
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
        .overlay {
            if showWinScreen {
                WinView(score: finalScore, stars: stars, onDismiss: {
                    showWinScreen = false
                    dismiss() // Возврат в главное меню
                }, onStartAgain: {
                    showWinScreen = false
                })
            }
            
            if showLoseScreen {
                LoseView(score: finalScore, difficulty: difficulty, onDismiss: {
                    showLoseScreen = false
                    dismiss() // Возврат в главное меню
                }, onStartAgain: {
                    // Restart game with same difficulty
                    restartGame = true
                    showLoseScreen = false
                })
            }
        }
        .onAppear {
            setupGame()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startGame()
            }
        }
        .onDisappear {
            endGame()
        }
        .onChange(of: restartGame) { shouldRestart in
            if shouldRestart {
                // Reset game state
                gameTime = difficulty.gameTime
                lives = difficulty.lives
                score = 0
                finalScore = 0
                stars = 0
                fallingObjects = []
                objectTimers.values.forEach { $0.invalidate() }
                objectTimers.removeAll()
                isGameActive = false
                
                // Restart after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    restartGame = false
                    setupGame()
                    startGame()
                }
            }
        }
    }
    
    private func setupGame() {
        viewModel.setModelContext(modelContext)
        gameTime = difficulty.gameTime
        lives = difficulty.lives
        viewModel.setLives(lives)
        viewModel.updateTime(gameTime)
    }
    
    private func startGame() {
        isGameActive = true
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isGameActive {
                gameTime -= 1
                viewModel.updateTime(gameTime)
                
                if gameTime <= 0 {
                    // Win!
                    endGame()
                    stars = calculateStars()
                    finalScore = score
                    viewModel.saveGameResult(isWin: true)
                    showWinScreen = true
                }
            }
        }
        
        // Start spawning objects
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { _ in
            if isGameActive && screenSize != .zero {
                spawnObject(in: screenSize)
            }
        }
    }
    
    private func spawnObject(in size: CGSize) {
        // Three spawn positions (like Android startPos1, startPos2, startPos3)
        let spawnPositions = [
            size.width / 6,      // Left third
            size.width / 2,      // Center
            size.width * 5 / 6   // Right third
        ]
        let spawnX = spawnPositions.randomElement() ?? size.width / 2
        
        // Randomly choose object type (75% eggs, 25% bombs)
        let isEgg = Double.random(in: 0...1) > 0.25
        let objectType: ObjectType = isEgg ? .egg : .bomb
        
        // Object size: 15% of screen width (from Android)
        let objectSize = size.width * 0.15
        
        // Use real images if available
        let objectView: AnyView
        if isEgg {
            let eggImages: [ResourceManager.ImageName] = [.egg1, .egg2, .egg3]
            if let eggImage = ResourceManager.shared.uiImage(named: eggImages.randomElement() ?? .egg1) {
                objectView = AnyView(
                    Image(uiImage: eggImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: objectSize, height: objectSize)
                        .rotationEffect(.degrees(Double.random(in: rotationMin...rotationMax)))
                )
            } else {
                objectView = AnyView(
                    Image(systemName: "egg.fill")
                        .font(.system(size: objectSize))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(Double.random(in: rotationMin...rotationMax)))
                )
            }
        } else {
            if let bombImage = ResourceManager.shared.uiImage(named: .bomb) {
                objectView = AnyView(
                    Image(uiImage: bombImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: objectSize, height: objectSize)
                        .rotationEffect(.degrees(Double.random(in: rotationMin...rotationMax)))
                )
            } else {
                objectView = AnyView(
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: objectSize))
                        .foregroundColor(.red)
                        .rotationEffect(.degrees(Double.random(in: rotationMin...rotationMax)))
                )
            }
        }
        
        // Start Y position: below clock icon (like Android startPos1/2/3 under icClock)
        // Calculate spawn Y based on HUD height
        let startY: CGFloat = hudHeight > 0 ? hudHeight : (size.height * 0.15)
        
        let fallingObject = FallingObject(
            id: UUID(),
            view: objectView,
            type: objectType,
            position: CGPoint(x: spawnX, y: startY),
            startTime: Date()
        )
        
        fallingObjects.append(fallingObject)
        
        // Animate fall and check collisions continuously
        let endY = size.height + 100
        let startTime = Date()
        
        let objectTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            DispatchQueue.main.async {
                guard self.isGameActive else {
                    timer.invalidate()
                    return
                }
                
                guard let index = self.fallingObjects.firstIndex(where: { $0.id == fallingObject.id }) else {
                    timer.invalidate()
                    return
                }
                
                let elapsed = Date().timeIntervalSince(startTime)
                let progress = min(elapsed / self.fallDuration, 1.0)
                
                let currentY = startY + (endY - startY) * CGFloat(progress)
                self.fallingObjects[index].position.y = currentY
                
                // Check collision continuously (like Android - when object reaches bird level)
                self.checkCollision(for: self.fallingObjects[index], in: size)
                
                if progress >= 1.0 {
                    timer.invalidate()
                    self.removeObject(fallingObject)
                }
            }
        }
        
        objectTimers[fallingObject.id] = objectTimer
    }
    
    private func checkCollision(for object: FallingObject, in size: CGSize) {
        guard isGameActive else { return }
        
        // Bird position and size
        let birdWidth = size.width * 0.25
        let birdHeight = birdWidth * 682.0 / 454.0
        let birdCenterX = birdPosition.x
        let birdTop = birdPosition.y - birdHeight / 2
        
        // Object position and size
        let objectSize = size.width * 0.15
        let objectCenterX = object.position.x
        let objectBottom = object.position.y + objectSize / 2
        
        // Check if object reached bird level (like Android: objectBottom >= birdTop)
        if objectBottom < birdTop {
            return // Object hasn't reached bird yet
        }
        
        // Check horizontal collision
        let distance = abs(birdCenterX - objectCenterX)
        let collisionRange = birdWidth / 2
        
        if distance < collisionRange {
            // Collision detected!
            handleCollision(type: object.type)
            removeObject(object)
        }
    }
    
    private func handleCollision(type: ObjectType) {
        switch type {
        case .egg:
            score += pointsPerEgg
            viewModel.addScore(pointsPerEgg)
            if settings.isSoundOn {
                // Play sound
            }
        case .bomb:
            lives -= 1
            viewModel.decrementLife()
            if settings.isVibrationOn {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
            
            if lives <= 0 {
                // Lose!
                endGame()
                finalScore = score
                viewModel.saveGameResult(isWin: false)
                showLoseScreen = true
            }
        }
    }
    
    private func removeObject(_ object: FallingObject) {
        objectTimers[object.id]?.invalidate()
        objectTimers.removeValue(forKey: object.id)
        fallingObjects.removeAll { $0.id == object.id }
    }
    
    private func calculateStars() -> Int {
        let maxLives = difficulty.lives
        if lives == maxLives {
            return 3
        } else if lives >= maxLives / 2 {
            return 2
        } else if lives > 0 {
            return 1
        }
        return 0
    }
    
    private func endGame() {
        isGameActive = false
        timer?.invalidate()
        spawnTimer?.invalidate()
        objectTimers.values.forEach { $0.invalidate() }
        objectTimers.removeAll()
        fallingObjects.removeAll()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

struct FallingObject: Identifiable {
    let id: UUID
    let view: AnyView
    let type: ObjectType
    var position: CGPoint
    let startTime: Date
}

#Preview {
    GameView(difficulty: .easy)
}
