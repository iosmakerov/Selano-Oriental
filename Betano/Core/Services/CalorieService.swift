import Foundation

struct CalorieService {
    
    private static let workMET: Double = 8.0
    private static let restMET: Double = 2.5
    private static let defaultWeight: Double = 70.0
    
    static func calculateCalories(
        workSeconds: Int,
        restSeconds: Int,
        weightKg: Double? = nil
    ) -> Int {
        let weight = weightKg ?? defaultWeight
        
        let workHours = Double(workSeconds) / 3600.0
        let restHours = Double(restSeconds) / 3600.0
        
        let workCalories = workMET * weight * workHours
        let restCalories = restMET * weight * restHours
        
        return Int(workCalories + restCalories)
    }
    
    static func caloriesForSession(_ session: Session) -> Int {
        calculateCalories(
            workSeconds: session.workTimeTotal,
            restSeconds: session.restTimeTotal
        )
    }
    
    static func estimatedCaloriesForWorkout(_ workout: Workout) -> Int {
        let totalWorkSeconds = workout.workDuration * workout.rounds
        let totalRestSeconds = workout.restDuration * workout.rounds
        
        return calculateCalories(
            workSeconds: totalWorkSeconds,
            restSeconds: totalRestSeconds
        )
    }
    
    static func formatCalories(_ calories: Int) -> String {
        if calories >= 1000 {
            return String(format: "%.1fk", Double(calories) / 1000.0)
        }
        return "\(calories)"
    }
}
