import SwiftUI

struct QuickStartView: View {
    @Binding var selectedWorkout: Workout?
    @StateObject private var storage = StorageService.shared
    @StateObject private var achievementService = AchievementService.shared
    @State private var showAchievements = false
    @State private var showStats = false
    @State private var showSettings = false
    
    let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]
    
    var lastSession: Session? {
        storage.sessionHistory.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Header with Quick Actions
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Quick Start")
                                .font(AppFonts.h1)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Tap to begin")
                                .font(AppFonts.bodyLarge)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: AppSpacing.sm) {
                            // Stats Button
                            QuickActionButton(icon: "chart.bar.fill") {
                                showStats = true
                            }
                            
                            // Achievements Button
                            ZStack(alignment: .topTrailing) {
                                QuickActionButton(icon: "trophy.fill") {
                                    showAchievements = true
                                }
                                
                                if achievementService.unlockedCount > 0 {
                                    Text("\(achievementService.unlockedCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(AppColors.boltRed)
                                        .clipShape(Circle())
                                        .offset(x: 4, y: -4)
                                }
                            }
                            
                            // Settings Button
                            QuickActionButton(icon: "gearshape.fill") {
                                showSettings = true
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    
                    // Last Workout Quick Repeat
                    if let session = lastSession {
                        LastWorkoutCard(session: session) {
                            repeatLastWorkout(session)
                        }
                        .padding(.horizontal, AppSpacing.md)
                    }
                    
                    // Featured Card
                    FeaturedPresetCard(workout: Workout.tabata) {
                        startWorkout(Workout.tabata)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    
                    // Section Title
                    Text("Popular Workouts")
                        .font(AppFonts.h3)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.top, AppSpacing.sm)
                    
                    // Preset Grid
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(Array(Workout.presets.dropFirst()), id: \.id) { preset in
                            PresetCardView(workout: preset) {
                                startWorkout(preset)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.md)
                    
                    Spacer().frame(height: AppSpacing.xl)
                }
                .padding(.top, AppSpacing.md)
            }
            .background(AppColors.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showStats) {
                StatsView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    private func startWorkout(_ workout: Workout) {
        selectedWorkout = workout
    }
    
    private func repeatLastWorkout(_ session: Session) {
        if let workout = storage.customWorkouts.first(where: { $0.id == session.workoutId }) {
            selectedWorkout = workout
        } else if let preset = Workout.presets.first(where: { $0.id == session.workoutId }) {
            selectedWorkout = preset
        } else {
            // Recreate workout from session
            selectedWorkout = Workout(
                id: session.workoutId,
                name: session.workoutName,
                workDuration: session.workTimeTotal / max(session.roundsTotal, 1),
                restDuration: session.restTimeTotal / max(session.roundsTotal - 1, 1),
                rounds: session.roundsTotal
            )
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 36, height: 36)
                .background(AppColors.backgroundCard)
                .clipShape(Circle())
        }
    }
}

// MARK: - Last Workout Card
struct LastWorkoutCard: View {
    let session: Session
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.shared.lightImpact()
            action()
        }) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.boltRed)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue Training")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(session.workoutName)
                        .font(AppFonts.h3)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text("\(session.formattedDuration) • \(session.roundsTotal) rounds")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textMuted)
            }
            .padding(AppSpacing.md)
            .background(AppColors.backgroundCard)
            .cornerRadius(AppCorners.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppCorners.large)
                    .stroke(AppColors.boltRed.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Featured Preset Card
struct FeaturedPresetCard: View {
    let workout: Workout
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.shared.lightImpact()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Text(workout.name)
                        .font(AppFonts.h2)
                        .foregroundColor(.white)
                    
                    Text(workout.formattedDuration)
                        .font(AppFonts.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(.white.opacity(0.2))
                        .cornerRadius(AppCorners.small)
                }
                
                Spacer()
                
                Image(systemName: "play.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(AppSpacing.lg)
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geometry in
                    ZStack {
                        Image("quickstart_featured_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        
                        LinearGradient(
                            colors: [AppColors.boltRed, AppColors.boltRedDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .opacity(0.9)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCorners.large))
        }
        .accessibilityLabel("Start \(workout.name)")
        .accessibilityHint("\(workout.formattedDuration) workout")
    }
}

// MARK: - Preset Card View
struct PresetCardView: View {
    let workout: Workout
    let action: () -> Void
    
    var iconName: String {
        switch workout.name {
        case "Sprint Intervals": return "figure.run"
        case "HIIT Burner": return "flame.fill"
        case "Beginner Pace": return "heart.fill"
        case "Pro Sprints": return "bolt.horizontal.fill"
        case "Endurance Build": return "timer"
        default: return "bolt.fill"
        }
    }
    
    var body: some View {
        Button(action: {
            HapticService.shared.lightImpact()
            action()
        }) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: iconName)
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.boltRed)
                    
                    Spacer()
                    
                    Text("\(workout.rounds)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColors.backgroundElevated)
                        .cornerRadius(AppCorners.small)
                }
                
                Spacer()
                
                Text(workout.name)
                    .font(AppFonts.h3)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(workout.formattedDuration)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(AppSpacing.md)
            .frame(height: 120)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.backgroundCard)
            .cornerRadius(AppCorners.large)
        }
        .accessibilityLabel(workout.name)
        .accessibilityHint("\(workout.formattedDuration), \(workout.rounds) rounds")
    }
}

#Preview {
    QuickStartView(selectedWorkout: .constant(nil))
}
