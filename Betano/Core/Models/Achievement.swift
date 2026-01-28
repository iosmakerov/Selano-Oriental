import Foundation

struct Achievement: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: AchievementRequirement
    var isUnlocked: Bool
    var unlockedAt: Date?
    
    enum AchievementRequirement: Codable {
        case totalSessions(Int)
        case totalMinutes(Int)
        case streak(Int)
        case perfectWeek
        case firstWorkout
        case customWorkouts(Int)
        case totalRounds(Int)
    }
}

extension Achievement {
    static let all: [Achievement] = [
        Achievement(
            id: "first_workout",
            title: "First Step",
            description: "Complete your first workout",
            icon: "figure.run",
            requirement: .firstWorkout,
            isUnlocked: false
        ),
        Achievement(
            id: "sessions_5",
            title: "Getting Started",
            description: "Complete 5 workouts",
            icon: "flame",
            requirement: .totalSessions(5),
            isUnlocked: false
        ),
        Achievement(
            id: "sessions_25",
            title: "Dedicated",
            description: "Complete 25 workouts",
            icon: "flame.fill",
            requirement: .totalSessions(25),
            isUnlocked: false
        ),
        Achievement(
            id: "sessions_100",
            title: "Unstoppable",
            description: "Complete 100 workouts",
            icon: "bolt.fill",
            requirement: .totalSessions(100),
            isUnlocked: false
        ),
        Achievement(
            id: "minutes_60",
            title: "Hour Power",
            description: "Train for 60 minutes total",
            icon: "clock",
            requirement: .totalMinutes(60),
            isUnlocked: false
        ),
        Achievement(
            id: "minutes_300",
            title: "5 Hour Club",
            description: "Train for 5 hours total",
            icon: "clock.fill",
            requirement: .totalMinutes(300),
            isUnlocked: false
        ),
        Achievement(
            id: "streak_3",
            title: "On Fire",
            description: "3 day workout streak",
            icon: "flame.circle",
            requirement: .streak(3),
            isUnlocked: false
        ),
        Achievement(
            id: "streak_7",
            title: "Week Warrior",
            description: "7 day workout streak",
            icon: "star.fill",
            requirement: .streak(7),
            isUnlocked: false
        ),
        Achievement(
            id: "streak_30",
            title: "Iron Will",
            description: "30 day workout streak",
            icon: "crown.fill",
            requirement: .streak(30),
            isUnlocked: false
        ),
        Achievement(
            id: "perfect_week",
            title: "Perfect Week",
            description: "Complete workouts 7 days in a row",
            icon: "checkmark.seal.fill",
            requirement: .perfectWeek,
            isUnlocked: false
        ),
        Achievement(
            id: "custom_1",
            title: "Creator",
            description: "Create your first custom workout",
            icon: "plus.circle.fill",
            requirement: .customWorkouts(1),
            isUnlocked: false
        ),
        Achievement(
            id: "custom_5",
            title: "Architect",
            description: "Create 5 custom workouts",
            icon: "hammer.fill",
            requirement: .customWorkouts(5),
            isUnlocked: false
        ),
        Achievement(
            id: "rounds_100",
            title: "Century",
            description: "Complete 100 rounds total",
            icon: "repeat.circle",
            requirement: .totalRounds(100),
            isUnlocked: false
        ),
        Achievement(
            id: "rounds_500",
            title: "Round Master",
            description: "Complete 500 rounds total",
            icon: "repeat.circle.fill",
            requirement: .totalRounds(500),
            isUnlocked: false
        )
    ]
}
