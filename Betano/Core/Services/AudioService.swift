import AVFoundation
import UIKit
import Combine

@MainActor
class AudioService {
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    private var isAudioSessionConfigured = false
    
    private init() {
        configureAudioSession()
    }
    

    func configureAudioSession() {
        guard !isAudioSessionConfigured else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            isAudioSessionConfigured = true
        } catch {
        }
    }
    

    func playWorkStart() {
        playSystemSound(.workStart)
    }
    
    func playRestStart() {
        playSystemSound(.restStart)
    }
    
    func playCountdownTick() {
        playSystemSound(.tick)
    }
    
    func playSessionComplete() {
        playSystemSound(.complete)
    }
    
    private enum SoundType {
        case workStart
        case restStart
        case tick
        case complete
        
        var systemSoundID: SystemSoundID {
            switch self {
            case .workStart: return 1304
            case .restStart: return 1306
            case .tick: return 1103
            case .complete: return 1025
            }
        }
    }
    
    private func playSystemSound(_ type: SoundType) {
        guard StorageService.shared.preferences.soundEnabled else { return }
        AudioServicesPlaySystemSound(type.systemSoundID)
    }
}
