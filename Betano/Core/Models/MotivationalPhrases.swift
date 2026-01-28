import Foundation

enum MotivationalPhrases {
    // MARK: - Work Phase
    static let workStart: [String] = [
        "Let's go!",
        "Push it!",
        "Give it all!",
        "You got this!",
        "Full power!",
        "Go hard!",
        "Beast mode!",
        "Crush it!"
    ]
    
    static let workMiddle: [String] = [
        "Keep pushing!",
        "Don't stop!",
        "Stay strong!",
        "Almost there!",
        "Keep going!",
        "You're crushing it!",
        "Feel the burn!",
        "Power through!"
    ]
    
    static let workEnd: [String] = [
        "Finish strong!",
        "Last seconds!",
        "Push through!",
        "Final effort!",
        "End it strong!"
    ]
    
    // MARK: - Rest Phase
    static let restStart: [String] = [
        "Breathe",
        "Recover",
        "Rest up",
        "Catch your breath",
        "Shake it off"
    ]
    
    static let restEnd: [String] = [
        "Get ready!",
        "Here we go!",
        "Next round!",
        "Prepare!",
        "Almost time!"
    ]
    
    // MARK: - Round Milestones
    static let halfwayDone: [String] = [
        "Halfway there!",
        "50% done!",
        "Halfway point!",
        "You're crushing it!"
    ]
    
    static let lastRound: [String] = [
        "Final round!",
        "Last one!",
        "Give it everything!",
        "Finish line ahead!",
        "Make it count!"
    ]
    
    // MARK: - Completion
    static let sessionComplete: [String] = [
        "Amazing work!",
        "You crushed it!",
        "Workout complete!",
        "Beast mode unlocked!",
        "Champion!",
        "Legendary!",
        "You're on fire!"
    ]
    
    // MARK: - Random Getters
    static func randomWorkStart() -> String {
        workStart.randomElement() ?? "Go!"
    }
    
    static func randomWorkMiddle() -> String {
        workMiddle.randomElement() ?? "Keep going!"
    }
    
    static func randomRestStart() -> String {
        restStart.randomElement() ?? "Rest"
    }
    
    static func randomRestEnd() -> String {
        restEnd.randomElement() ?? "Get ready!"
    }
    
    static func randomComplete() -> String {
        sessionComplete.randomElement() ?? "Great work!"
    }
    
    static func randomHalfway() -> String {
        halfwayDone.randomElement() ?? "Halfway!"
    }
    
    static func randomLastRound() -> String {
        lastRound.randomElement() ?? "Final round!"
    }
}
