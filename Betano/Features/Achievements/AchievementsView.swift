import SwiftUI

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var achievementService = AchievementService.shared
    
    let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {

                        progressHeader
                        

                        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                            ForEach(achievementService.achievements) { achievement in
                                AchievementCard(achievement: achievement)
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                    }
                    .padding(.top, AppSpacing.md)
                }
            }
            .navigationTitle("Achievements")
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
    
    private var progressHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundElevated, lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: achievementService.progressPercentage)
                    .stroke(
                        AppColors.boltRed,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(achievementService.unlockedCount)")
                        .font(AppFonts.h1)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("of \(achievementService.totalCount)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .frame(width: 100, height: 100)
            
            Text("Achievements Unlocked")
                .font(AppFonts.bodyLarge)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.lg)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? AppColors.boltRed : AppColors.backgroundElevated)
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 28))
                    .foregroundColor(achievement.isUnlocked ? .white : AppColors.textMuted)
            }
            
            Text(achievement.title)
                .font(AppFonts.h3)
                .foregroundColor(achievement.isUnlocked ? AppColors.textPrimary : AppColors.textMuted)
                .lineLimit(1)
            
            Text(achievement.description)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if let unlockedAt = achievement.unlockedAt {
                Text(unlockedAt, style: .date)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.boltRed)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.large)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

struct AchievementUnlockedView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Achievement Unlocked!")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.boltRed)
            
            ZStack {
                Circle()
                    .fill(AppColors.boltRed)
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: AppSpacing.xs) {
                Text(achievement.title)
                    .font(AppFonts.h2)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(achievement.description)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            PrimaryButton(title: "Awesome!", action: onDismiss)
                .frame(maxWidth: 200)
        }
        .padding(AppSpacing.xl)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.large)
        .shadow(color: .black.opacity(0.3), radius: 20)
    }
}

#Preview {
    AchievementsView()
}
