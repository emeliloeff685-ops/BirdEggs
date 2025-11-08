//
//  MusicPlayer.swift
//  BirdEggs
//
//  Created by User You on 11/8/25.
//

import AVFoundation
import Combine

class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    private init() {}
    
    func playMusic() {
        guard let url = ResourceManager.shared.musicURL else {
            print("Music file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing music: \(error)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

