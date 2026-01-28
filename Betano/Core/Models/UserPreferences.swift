import Foundation

enum TrainingFocus: String, Codable, CaseIterable {
    case sprint = "sprint"
    case hiit = "hiit"
    case interval = "interval"
    case general = "general"
    
    var title: String {
        switch self {
        case .sprint: return "Sprint Training"
        case .hiit: return "HIIT Workouts"
        case .interval: return "Interval Running"
        case .general: return "General Fitness"
        }
    }
    
    var icon: String {
        switch self {
        case .sprint: return "bolt.fill"
        case .hiit: return "flame.fill"
        case .interval: return "figure.run"
        case .general: return "dumbbell.fill"
        }
    }
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var title: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    var subtitle: String {
        switch self {
        case .beginner: return "Just starting out"
        case .intermediate: return "Regular training"
        case .advanced: return "Competitive athlete"
        }
    }
}

struct UserPreferences: Codable {
    var trainingFocus: TrainingFocus
    var experienceLevel: ExperienceLevel
    var soundEnabled: Bool
    var hapticEnabled: Bool
    var voiceCuesEnabled: Bool
    var defaultCountdown: Int // 3, 5, or 10
    var keepScreenOn: Bool
    var backgroundAudioEnabled: Bool
    
    static var `default`: UserPreferences {
        UserPreferences(
            trainingFocus: .general,
            experienceLevel: .beginner,
            soundEnabled: true,
            hapticEnabled: true,
            voiceCuesEnabled: false,
            defaultCountdown: 3,
            keepScreenOn: true,
            backgroundAudioEnabled: true
        )
    }
}
