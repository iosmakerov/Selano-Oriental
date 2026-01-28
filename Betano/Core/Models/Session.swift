import Foundation

struct Session: Codable, Identifiable {
    let id: UUID
    let workoutId: UUID
    let workoutName: String
    let startedAt: Date
    let completedAt: Date?
    let totalDuration: Int // seconds actually elapsed
    let roundsCompleted: Int
    let roundsTotal: Int
    let workTimeTotal: Int // seconds
    let restTimeTotal: Int // seconds
    var completionPercentage: Double // 0.0 - 1.0
    var caloriesBurned: Int // estimated calories
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startedAt)
    }
    
    var formattedDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var completionText: String {
        "\(Int(completionPercentage * 100))% Complete"
    }
    
    var isCompleted: Bool {
        completionPercentage >= 1.0
    }
    
    init(
        id: UUID = UUID(),
        workoutId: UUID,
        workoutName: String,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        totalDuration: Int,
        roundsCompleted: Int,
        roundsTotal: Int,
        workTimeTotal: Int,
        restTimeTotal: Int,
        completionPercentage: Double,
        caloriesBurned: Int? = nil
    ) {
        self.id = id
        self.workoutId = workoutId
        self.workoutName = workoutName
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.totalDuration = totalDuration
        self.roundsCompleted = roundsCompleted
        self.roundsTotal = roundsTotal
        self.workTimeTotal = workTimeTotal
        self.restTimeTotal = restTimeTotal
        self.completionPercentage = completionPercentage
        self.caloriesBurned = caloriesBurned ?? CalorieService.calculateCalories(
            workSeconds: workTimeTotal,
            restSeconds: restTimeTotal
        )
    }
}

// MARK: - Grouping
extension Session {
    static func groupByDate(_ sessions: [Session]) -> [(String, [Session])] {
        let calendar = Calendar.current
        let now = Date()
        
        var today: [Session] = []
        var yesterday: [Session] = []
        var thisWeek: [Session] = []
        var earlier: [Session] = []
        
        for session in sessions.sorted(by: { $0.startedAt > $1.startedAt }) {
            if calendar.isDateInToday(session.startedAt) {
                today.append(session)
            } else if calendar.isDateInYesterday(session.startedAt) {
                yesterday.append(session)
            } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: now),
                      session.startedAt > weekAgo {
                thisWeek.append(session)
            } else {
                earlier.append(session)
            }
        }
        
        var result: [(String, [Session])] = []
        if !today.isEmpty { result.append(("Today", today)) }
        if !yesterday.isEmpty { result.append(("Yesterday", yesterday)) }
        if !thisWeek.isEmpty { result.append(("This Week", thisWeek)) }
        if !earlier.isEmpty { result.append(("Earlier", earlier)) }
        
        return result
    }
}
