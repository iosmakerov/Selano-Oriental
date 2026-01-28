import SwiftUI

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storage = StorageService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Weekly Overview
                        weeklyOverviewCard
                        
                        // Weekly Chart
                        weeklyChartCard
                        
                        // All Time Stats
                        allTimeStatsCard
                        
                        // Personal Records
                        personalRecordsCard
                    }
                    .padding(AppSpacing.md)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.boltRed)
                }
            }
        }
    }
    
    // MARK: - Weekly Overview
    private var weeklyOverviewCard: some View {
        let stats = storage.weeklyStats
        
        return VStack(spacing: AppSpacing.md) {
            Text("This Week")
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: AppSpacing.lg) {
                StatBlock(value: "\(stats.sessions)", label: "Workouts", icon: "flame.fill")
                StatBlock(value: formatMinutes(stats.totalTime), label: "Active", icon: "clock.fill")
                StatBlock(value: "\(stats.streak)", label: "Streak", icon: "bolt.fill")
                StatBlock(value: "\(weeklyCalories)", label: "Calories", icon: "flame.circle.fill")
            }
        }
        .padding(AppSpacing.lg)
        .background(
            LinearGradient(
                colors: [AppColors.boltRed.opacity(0.2), AppColors.backgroundCard],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppCorners.large)
    }
    
    private var weeklyCalories: Int {
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return 0 }
        
        return storage.sessionHistory
            .filter { $0.startedAt > weekAgo }
            .reduce(0) { $0 + $1.caloriesBurned }
    }
    
    // MARK: - Weekly Chart
    private var weeklyChartCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Activity This Week")
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(alignment: .bottom, spacing: AppSpacing.sm) {
                ForEach(weeklyData, id: \.day) { data in
                    VStack(spacing: AppSpacing.xs) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(data.minutes > 0 ? AppColors.boltRed : AppColors.backgroundElevated)
                            .frame(width: 36, height: max(CGFloat(data.minutes) * 2, 4))
                        
                        Text(data.day)
                            .font(AppFonts.caption)
                            .foregroundColor(data.isToday ? AppColors.boltRed : AppColors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120, alignment: .bottom)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.large)
    }
    
    private var weeklyData: [(day: String, minutes: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = Date()
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        
        return (0..<7).map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -6 + daysAgo, to: today)!
            let dayOfWeek = calendar.component(.weekday, from: date) - 1
            let isToday = calendar.isDateInToday(date)
            
            let minutes = storage.sessionHistory
                .filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
                .reduce(0) { $0 + $1.totalDuration } / 60
            
            return (weekdays[dayOfWeek], minutes, isToday)
        }
    }
    
    // MARK: - All Time Stats
    private var allTimeStatsCard: some View {
        let allTime = allTimeStats
        
        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("All Time")
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: AppSpacing.sm) {
                AllTimeStatRow(icon: "flame.fill", title: "Total Workouts", value: "\(allTime.sessions)")
                AllTimeStatRow(icon: "clock.fill", title: "Total Time", value: formatHours(allTime.totalMinutes))
                AllTimeStatRow(icon: "repeat.circle.fill", title: "Total Rounds", value: "\(allTime.rounds)")
                AllTimeStatRow(icon: "flame.circle.fill", title: "Total Calories", value: "\(allTime.calories) kcal")
                AllTimeStatRow(icon: "calendar", title: "First Workout", value: allTime.firstWorkoutDate)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.large)
    }
    
    private var allTimeStats: (sessions: Int, totalMinutes: Int, rounds: Int, calories: Int, firstWorkoutDate: String) {
        let sessions = storage.sessionHistory
        let totalMinutes = sessions.reduce(0) { $0 + $1.totalDuration } / 60
        let rounds = sessions.reduce(0) { $0 + $1.roundsCompleted }
        let calories = sessions.reduce(0) { $0 + $1.caloriesBurned }
        
        let firstDate: String
        if let first = sessions.last?.startedAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            firstDate = formatter.string(from: first)
        } else {
            firstDate = "—"
        }
        
        return (sessions.count, totalMinutes, rounds, calories, firstDate)
    }
    
    // MARK: - Personal Records
    private var personalRecordsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Personal Records")
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: AppSpacing.md) {
                RecordCard(title: "Longest Session", value: longestSession, icon: "timer")
                RecordCard(title: "Most Rounds", value: "\(mostRounds)", icon: "repeat.circle")
            }
            
            HStack(spacing: AppSpacing.md) {
                RecordCard(title: "Best Streak", value: "\(bestStreak) days", icon: "flame")
                RecordCard(title: "Most Calories", value: "\(mostCalories) kcal", icon: "flame.circle")
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.large)
    }
    
    private var longestSession: String {
        let longest = storage.sessionHistory.max(by: { $0.totalDuration < $1.totalDuration })?.totalDuration ?? 0
        return formatMinutes(longest)
    }
    
    private var mostRounds: Int {
        storage.sessionHistory.max(by: { $0.roundsCompleted < $1.roundsCompleted })?.roundsCompleted ?? 0
    }
    
    private var bestStreak: Int {
        storage.weeklyStats.streak // Simplified - would need historical tracking for true best
    }
    
    private var mostCalories: Int {
        storage.sessionHistory.max(by: { $0.caloriesBurned < $1.caloriesBurned })?.caloriesBurned ?? 0
    }
    
    // MARK: - Helpers
    private func formatMinutes(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
    }
    
    private func formatHours(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins) min"
    }
}

// MARK: - Supporting Views
struct StatBlock: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.boltRed)
            
            Text(value)
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AllTimeStatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.boltRed)
                .frame(width: 24)
            
            Text(title)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

struct RecordCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.boltRed)
            
            Text(value)
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(AppColors.backgroundElevated)
        .cornerRadius(AppCorners.medium)
    }
}

#Preview {
    StatsView()
}
