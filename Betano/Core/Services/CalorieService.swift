import Foundation

struct CalorieService {
    // MET values for interval training
    // MET = Metabolic Equivalent of Task
    private static let workMET: Double = 8.0  // High intensity
    private static let restMET: Double = 2.5  // Light activity/recovery
    
    // Default weight if not set (kg)
    private static let defaultWeight: Double = 70.0
    
    /// Calculate estimated calories burned during a workout
    /// Formula: Calories = MET × Weight(kg) × Duration(hours)
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
    
    /// Calculate calories for a completed session
    static func caloriesForSession(_ session: Session) -> Int {
        calculateCalories(
            workSeconds: session.workTimeTotal,
            restSeconds: session.restTimeTotal
        )
    }
    
    /// Calculate estimated calories for a workout
    static func estimatedCaloriesForWorkout(_ workout: Workout) -> Int {
        let totalWorkSeconds = workout.workDuration * workout.rounds
        let totalRestSeconds = workout.restDuration * workout.rounds
        
        return calculateCalories(
            workSeconds: totalWorkSeconds,
            restSeconds: totalRestSeconds
        )
    }
    
    /// Format calories for display
    static func formatCalories(_ calories: Int) -> String {
        if calories >= 1000 {
            return String(format: "%.1fk", Double(calories) / 1000.0)
        }
        return "\(calories)"
    }
}
