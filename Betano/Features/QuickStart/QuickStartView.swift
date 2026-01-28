import SwiftUI

struct QuickStartView: View {
    @Binding var selectedWorkout: Workout?
    
    let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Quick Start")
                            .font(AppFonts.h1)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Tap to begin")
                            .font(AppFonts.bodyLarge)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    
                    // Featured Card
                    FeaturedPresetCard(workout: Workout.tabata) {
                        startWorkout(Workout.tabata)
                    }
                    .padding(.horizontal, AppSpacing.md)
                    
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
        }
    }
    
    private func startWorkout(_ workout: Workout) {
        selectedWorkout = workout
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
