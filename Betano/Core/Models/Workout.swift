import Foundation

struct Workout: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var workDuration: Int // seconds
    var restDuration: Int // seconds
    var rounds: Int
    var warmupDuration: Int // seconds, default 0
    var cooldownDuration: Int // seconds, default 0
    var countdownDuration: Int // seconds, default 3
    let createdAt: Date
    var lastUsedAt: Date?
    var isPreset: Bool // true for built-in presets
    
    var totalDuration: Int {
        warmupDuration + (workDuration + restDuration) * rounds + cooldownDuration
    }
    
    var formattedDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        if seconds == 0 {
            return "\(minutes) min"
        }
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
    
    var intervalSummary: String {
        "\(rounds) rounds • \(workDuration)s/\(restDuration)s"
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        workDuration: Int,
        restDuration: Int,
        rounds: Int,
        warmupDuration: Int = 0,
        cooldownDuration: Int = 0,
        countdownDuration: Int = 3,
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil,
        isPreset: Bool = false
    ) {
        self.id = id
        self.name = name
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.rounds = rounds
        self.warmupDuration = warmupDuration
        self.cooldownDuration = cooldownDuration
        self.countdownDuration = countdownDuration
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.isPreset = isPreset
    }
}

// MARK: - Presets
extension Workout {
    static let presets: [Workout] = [
        Workout(
            name: "Classic Tabata",
            workDuration: 20,
            restDuration: 10,
            rounds: 8,
            isPreset: true
        ),
        Workout(
            name: "Sprint Intervals",
            workDuration: 30,
            restDuration: 60,
            rounds: 6,
            isPreset: true
        ),
        Workout(
            name: "HIIT Burner",
            workDuration: 45,
            restDuration: 15,
            rounds: 10,
            isPreset: true
        ),
        Workout(
            name: "Beginner Pace",
            workDuration: 20,
            restDuration: 40,
            rounds: 6,
            isPreset: true
        ),
        Workout(
            name: "Pro Sprints",
            workDuration: 15,
            restDuration: 45,
            rounds: 12,
            isPreset: true
        ),
        Workout(
            name: "Endurance Build",
            workDuration: 60,
            restDuration: 30,
            rounds: 8,
            isPreset: true
        )
    ]
    
    static var tabata: Workout {
        presets[0]
    }
}
