import Foundation
import Combine

@MainActor
class AchievementService: ObservableObject {
    static let shared = AchievementService()
    
    @Published var achievements: [Achievement] = []
    @Published var newlyUnlocked: Achievement?
    
    private let defaults = UserDefaults.standard
    private let key = "user_achievements"
    
    private init() {
        loadAchievements()
    }
    
    // MARK: - Load/Save
    private func loadAchievements() {
        if let data = defaults.data(forKey: key),
           let saved = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Merge saved with all achievements (in case new ones were added)
            var merged = Achievement.all
            for saved in saved where saved.isUnlocked {
                if let index = merged.firstIndex(where: { $0.id == saved.id }) {
                    merged[index].isUnlocked = true
                    merged[index].unlockedAt = saved.unlockedAt
                }
            }
            achievements = merged
        } else {
            achievements = Achievement.all
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            defaults.set(data, forKey: key)
        }
    }
    
    // MARK: - Check Achievements
    func checkAchievements(storage: StorageService) {
        let sessions = storage.sessionHistory
        let customWorkouts = storage.customWorkouts
        let stats = storage.weeklyStats
        
        // Calculate totals
        let totalSessions = sessions.count
        let totalMinutes = sessions.reduce(0) { $0 + $1.totalDuration } / 60
        let totalRounds = sessions.reduce(0) { $0 + $1.roundsCompleted }
        let streak = stats.streak
        
        for index in achievements.indices where !achievements[index].isUnlocked {
            var shouldUnlock = false
            
            switch achievements[index].requirement {
            case .firstWorkout:
                shouldUnlock = totalSessions >= 1
            case .totalSessions(let count):
                shouldUnlock = totalSessions >= count
            case .totalMinutes(let minutes):
                shouldUnlock = totalMinutes >= minutes
            case .totalRounds(let rounds):
                shouldUnlock = totalRounds >= rounds
            case .streak(let days):
                shouldUnlock = streak >= days
            case .perfectWeek:
                shouldUnlock = streak >= 7
            case .customWorkouts(let count):
                shouldUnlock = customWorkouts.count >= count
            }
            
            if shouldUnlock {
                achievements[index].isUnlocked = true
                achievements[index].unlockedAt = Date()
                newlyUnlocked = achievements[index]
                
                HapticService.shared.sessionComplete()
            }
        }
        
        saveAchievements()
    }
    
    // MARK: - Stats
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
    
    var progressPercentage: Double {
        Double(unlockedCount) / Double(totalCount)
    }
    
    func dismissNewAchievement() {
        newlyUnlocked = nil
    }
}
