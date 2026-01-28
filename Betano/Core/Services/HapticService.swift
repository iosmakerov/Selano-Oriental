import UIKit
import Combine

@MainActor
class HapticService {
    static let shared = HapticService()
    
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        prepareGenerators()
    }
    
    private func prepareGenerators() {
        notificationGenerator.prepare()
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionGenerator.prepare()
    }
    
    private var isEnabled: Bool {
        StorageService.shared.preferences.hapticEnabled
    }
    
    // MARK: - Phase Transitions
    func phaseChange() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred()
    }
    
    func workStart() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }
    
    func restStart() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }
    
    // MARK: - Countdown
    func countdownTick() {
        guard isEnabled else { return }
        impactMedium.impactOccurred()
    }
    
    // MARK: - Session
    func sessionComplete() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    // MARK: - UI Feedback
    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }
    
    func lightImpact() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }
    
    func error() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }
}
