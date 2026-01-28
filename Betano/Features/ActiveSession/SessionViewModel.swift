import Foundation
import Combine
import UIKit

enum SessionPhase: Sendable {
    case countdown
    case warmup
    case work
    case rest
    case cooldown
    case completed
    
    var displayName: String {
        switch self {
        case .countdown: return "GET READY"
        case .warmup: return "WARM UP"
        case .work: return "WORK"
        case .rest: return "REST"
        case .cooldown: return "COOL DOWN"
        case .completed: return "COMPLETE"
        }
    }
}

@MainActor
class SessionViewModel: ObservableObject {

    @Published var currentPhase: SessionPhase = .countdown
    @Published var timeRemaining: Int = 0
    @Published var currentRound: Int = 1
    @Published var isPaused: Bool = false
    @Published var isCompleted: Bool = false
    @Published var totalElapsedTime: Int = 0
    @Published var motivationalText: String = ""
    @Published var showMotivation: Bool = false
    

    let workout: Workout
    private var timer: AnyCancellable?
    private var startTime: Date?
    private var workTimeAccumulated: Int = 0
    private var restTimeAccumulated: Int = 0
    private let storage = StorageService.shared
    private let achievementService = AchievementService.shared
    
    var progress: Double {
        guard timeRemaining > 0 else { return 1.0 }
        let totalPhaseTime = currentPhaseDuration
        return 1.0 - Double(timeRemaining) / Double(totalPhaseTime)
    }
    
    private var currentPhaseDuration: Int {
        switch currentPhase {
        case .countdown: return workout.countdownDuration
        case .warmup: return workout.warmupDuration
        case .work: return workout.workDuration
        case .rest: return workout.restDuration
        case .cooldown: return workout.cooldownDuration
        case .completed: return 0
        }
    }
    
    var nextPhaseText: String {
        switch currentPhase {
        case .countdown:
            if workout.warmupDuration > 0 {
                return "Next: WARM UP \(workout.warmupDuration)s"
            }
            return "Next: WORK \(workout.workDuration)s"
        case .warmup:
            return "Next: WORK \(workout.workDuration)s"
        case .work:
            return "Next: REST \(workout.restDuration)s"
        case .rest:
            if currentRound < workout.rounds {
                return "Next: WORK \(workout.workDuration)s"
            } else if workout.cooldownDuration > 0 {
                return "Next: COOL DOWN"
            }
            return "Final round!"
        case .cooldown, .completed:
            return ""
        }
    }
    
    var roundText: String {
        "Round \(currentRound)/\(workout.rounds)"
    }
    
    var completionPercentage: Double {
        let totalPhases = workout.rounds * 2
        let completedPhases: Int
        
        switch currentPhase {
        case .countdown, .warmup:
            completedPhases = 0
        case .work:
            completedPhases = (currentRound - 1) * 2
        case .rest:
            completedPhases = (currentRound - 1) * 2 + 1
        case .cooldown:
            completedPhases = totalPhases
        case .completed:
            return 1.0
        }
        
        return Double(completedPhases) / Double(totalPhases)
    }
    

    init(workout: Workout) {
        self.workout = workout
        setupInitialState()
    }
    
    private func setupInitialState() {
        currentPhase = .countdown
        timeRemaining = workout.countdownDuration
        currentRound = 1
        startTime = Date()
    }
    

    func start() {
        startTimer()
        keepScreenOn(true)
        AudioService.shared.configureAudioSession()
    }
    
    func pause() {
        isPaused = true
        timer?.cancel()
    }
    
    func resume() {
        isPaused = false
        startTimer()
    }
    
    func stop() {
        timer?.cancel()
        keepScreenOn(false)
        saveSession()
    }
    
    func skipPhase() {
        timeRemaining = 0
        handlePhaseComplete()
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        guard !isPaused else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            totalElapsedTime += 1
            

            if currentPhase == .work {
                workTimeAccumulated += 1
                

                if timeRemaining == currentPhaseDuration - 1 {
                    showMotivationalText(MotivationalPhrases.randomWorkStart())
                } else if timeRemaining == 5 {
                    showMotivationalText(MotivationalPhrases.workEnd.randomElement() ?? "Finish!")
                }
            } else if currentPhase == .rest {
                restTimeAccumulated += 1
                

                if timeRemaining == 3 {
                    showMotivationalText(MotivationalPhrases.randomRestEnd())
                }
            }
            

            if currentRound == workout.rounds / 2 && currentPhase == .work && timeRemaining == currentPhaseDuration - 1 {
                showMotivationalText(MotivationalPhrases.randomHalfway())
            }
            

            if currentRound == workout.rounds && currentPhase == .work && timeRemaining == currentPhaseDuration - 1 {
                showMotivationalText(MotivationalPhrases.randomLastRound())
            }
            

            if timeRemaining <= 3 && timeRemaining > 0 {
                AudioService.shared.playCountdownTick()
                HapticService.shared.countdownTick()
            }
        }
        
        if timeRemaining == 0 {
            handlePhaseComplete()
        }
    }
    
    private func showMotivationalText(_ text: String) {
        motivationalText = text
        showMotivation = true
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showMotivation = false
        }
    }
    
    private func handlePhaseComplete() {
        switch currentPhase {
        case .countdown:
            if workout.warmupDuration > 0 {
                transitionTo(.warmup, duration: workout.warmupDuration)
            } else {
                transitionTo(.work, duration: workout.workDuration)
            }
            
        case .warmup:
            transitionTo(.work, duration: workout.workDuration)
            
        case .work:
            AudioService.shared.playRestStart()
            HapticService.shared.restStart()
            transitionTo(.rest, duration: workout.restDuration)
            
        case .rest:
            if currentRound < workout.rounds {
                currentRound += 1
                AudioService.shared.playWorkStart()
                HapticService.shared.workStart()
                transitionTo(.work, duration: workout.workDuration)
            } else if workout.cooldownDuration > 0 {
                transitionTo(.cooldown, duration: workout.cooldownDuration)
            } else {
                completeSession()
            }
            
        case .cooldown:
            completeSession()
            
        case .completed:
            break
        }
    }
    
    private func transitionTo(_ phase: SessionPhase, duration: Int) {
        currentPhase = phase
        timeRemaining = duration
        
        if phase == .work {
            AudioService.shared.playWorkStart()
            HapticService.shared.workStart()
        }
    }
    
    private func completeSession() {
        timer?.cancel()
        currentPhase = .completed
        isCompleted = true
        keepScreenOn(false)
        
        AudioService.shared.playSessionComplete()
        HapticService.shared.sessionComplete()
        
        saveSession()
    }
    
    private func saveSession() {
        let session = Session(
            workoutId: workout.id,
            workoutName: workout.name,
            startedAt: startTime ?? Date(),
            completedAt: Date(),
            totalDuration: totalElapsedTime,
            roundsCompleted: isCompleted ? workout.rounds : currentRound - 1,
            roundsTotal: workout.rounds,
            workTimeTotal: workTimeAccumulated,
            restTimeTotal: restTimeAccumulated,
            completionPercentage: completionPercentage
        )
        storage.addSession(session)
        

        achievementService.checkAchievements(storage: storage)
    }
    

    var estimatedCalories: Int {
        CalorieService.calculateCalories(
            workSeconds: workTimeAccumulated,
            restSeconds: restTimeAccumulated
        )
    }
    
    private func keepScreenOn(_ on: Bool) {
        if storage.preferences.keepScreenOn {
            UIApplication.shared.isIdleTimerDisabled = on
        }
    }
}
