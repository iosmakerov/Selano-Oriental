import Foundation
import Combine

@MainActor
class StorageService: ObservableObject {
    static let shared = StorageService()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let onboardingCompleted = "onboarding_completed"
        static let userPreferences = "user_preferences"
        static let customWorkouts = "custom_workouts"
        static let sessionHistory = "session_history"
        static let appLaunchCount = "app_launch_count"
        static let dataSchemaVersion = "data_schema_version"
    }
    
    // MARK: - Published Properties
    @Published var onboardingCompleted: Bool {
        didSet {
            defaults.set(onboardingCompleted, forKey: Keys.onboardingCompleted)
        }
    }
    
    @Published var preferences: UserPreferences {
        didSet {
            savePreferences(preferences)
        }
    }
    
    @Published var customWorkouts: [Workout] {
        didSet {
            saveWorkouts(customWorkouts)
        }
    }
    
    @Published var sessionHistory: [Session] {
        didSet {
            saveSessions(sessionHistory)
        }
    }
    
    // MARK: - Init
    private init() {
        self.onboardingCompleted = defaults.bool(forKey: Keys.onboardingCompleted)
        self.preferences = Self.loadPreferences()
        self.customWorkouts = Self.loadWorkouts()
        self.sessionHistory = Self.loadSessions()
        
        incrementLaunchCount()
    }
    
    // MARK: - Preferences
    private static func loadPreferences() -> UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: Keys.userPreferences) else {
            return .default
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode(UserPreferences.self, from: data)) ?? .default
    }
    
    private func savePreferences(_ preferences: UserPreferences) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(preferences) {
            defaults.set(data, forKey: Keys.userPreferences)
        }
    }
    
    // MARK: - Workouts
    private static func loadWorkouts() -> [Workout] {
        guard let data = UserDefaults.standard.data(forKey: Keys.customWorkouts) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Workout].self, from: data)) ?? []
    }
    
    private func saveWorkouts(_ workouts: [Workout]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(workouts) {
            defaults.set(data, forKey: Keys.customWorkouts)
        }
    }
    
    func addWorkout(_ workout: Workout) {
        customWorkouts.append(workout)
    }
    
    func updateWorkout(_ workout: Workout) {
        if let index = customWorkouts.firstIndex(where: { $0.id == workout.id }) {
            customWorkouts[index] = workout
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        customWorkouts.removeAll { $0.id == workout.id }
    }
    
    func markWorkoutAsUsed(_ workout: Workout) {
        if let index = customWorkouts.firstIndex(where: { $0.id == workout.id }) {
            var updated = customWorkouts[index]
            updated.lastUsedAt = Date()
            customWorkouts[index] = updated
        }
    }
    
    // MARK: - Sessions
    private static func loadSessions() -> [Session] {
        guard let data = UserDefaults.standard.data(forKey: Keys.sessionHistory) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Session].self, from: data)) ?? []
    }
    
    private func saveSessions(_ sessions: [Session]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(sessions) {
            defaults.set(data, forKey: Keys.sessionHistory)
        }
    }
    
    func addSession(_ session: Session) {
        sessionHistory.insert(session, at: 0)
    }
    
    func deleteSession(_ session: Session) {
        sessionHistory.removeAll { $0.id == session.id }
    }
    
    func clearHistory() {
        sessionHistory.removeAll()
    }
    
    // MARK: - Stats
    var weeklyStats: (sessions: Int, totalTime: Int, streak: Int) {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            return (0, 0, 0)
        }
        
        let weeklySessions = sessionHistory.filter { $0.startedAt > weekAgo }
        let totalTime = weeklySessions.reduce(0) { $0 + $1.totalDuration }
        
        // Calculate streak
        var streak = 0
        var currentDate = Date()
        
        while true {
            let hasSessionOnDate = sessionHistory.contains { session in
                calendar.isDate(session.startedAt, inSameDayAs: currentDate)
            }
            
            if hasSessionOnDate {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else if !calendar.isDateInToday(currentDate) {
                break
            } else {
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            }
        }
        
        return (weeklySessions.count, totalTime, streak)
    }
    
    // MARK: - Launch Count
    private func incrementLaunchCount() {
        let count = defaults.integer(forKey: Keys.appLaunchCount)
        defaults.set(count + 1, forKey: Keys.appLaunchCount)
    }
    
    var launchCount: Int {
        defaults.integer(forKey: Keys.appLaunchCount)
    }
    
    // MARK: - Reset
    func resetToDefaults() {
        preferences = .default
    }
}
