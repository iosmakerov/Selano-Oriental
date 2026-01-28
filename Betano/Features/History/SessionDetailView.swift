import SwiftUI

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storage = StorageService.shared
    
    let session: Session
    let onRepeat: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Completion Badge
                        completionBadge
                        
                        // Stats Grid
                        statsGrid
                        
                        // Timeline (optional enhancement)
                        timelineView
                        
                        Spacer().frame(height: AppSpacing.lg)
                        
                        // Actions
                        VStack(spacing: AppSpacing.md) {
                            PrimaryButton(title: "Repeat Workout") {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onRepeat()
                                }
                            }
                            
                            TextButton(title: "Delete Session") {
                                showDeleteConfirmation = true
                            }
                        }
                        .padding(.horizontal, AppSpacing.md)
                    }
                    .padding(.top, AppSpacing.lg)
                }
            }
            .navigationTitle(session.workoutName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .alert("Delete Session?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    storage.deleteSession(session)
                    dismiss()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Completion Badge
    private var completionBadge: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundElevated, lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: session.completionPercentage)
                    .stroke(
                        session.isCompleted ? AppColors.success : AppColors.warning,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8), value: session.completionPercentage)
                
                VStack(spacing: AppSpacing.xs) {
                    Text("\(Int(session.completionPercentage * 100))%")
                        .font(AppFonts.h1)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Complete")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .frame(width: 140, height: 140)
            
            if session.isCompleted {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    
                    Text("Session Completed")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.success)
                }
            }
        }
        .padding(.vertical, AppSpacing.lg)
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                StatCard(icon: "calendar", title: "Date", value: formatDate(session.startedAt))
                StatCard(icon: "clock", title: "Duration", value: session.formattedDuration)
            }
            
            HStack(spacing: AppSpacing.md) {
                StatCard(icon: "arrow.trianglehead.counterclockwise.rotate.90", title: "Rounds", value: "\(session.roundsCompleted)/\(session.roundsTotal)")
                StatCard(icon: "flame.fill", title: "Work Time", value: formatDuration(session.workTimeTotal))
            }
            
            HStack(spacing: AppSpacing.md) {
                StatCard(icon: "pause.circle", title: "Rest Time", value: formatDuration(session.restTimeTotal))
                StatCard(icon: "bolt.fill", title: "Intensity", value: intensityLabel)
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }
    
    private var intensityLabel: String {
        let workRatio = Double(session.workTimeTotal) / Double(max(session.workTimeTotal + session.restTimeTotal, 1))
        if workRatio > 0.6 {
            return "High"
        } else if workRatio > 0.4 {
            return "Medium"
        }
        return "Low"
    }
    
    // MARK: - Timeline
    private var timelineView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Session Timeline")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.md)
            
            HStack(spacing: 2) {
                ForEach(0..<session.roundsTotal, id: \.self) { round in
                    HStack(spacing: 1) {
                        Rectangle()
                            .fill(round < session.roundsCompleted ? AppColors.workPhase : AppColors.backgroundElevated)
                        
                        Rectangle()
                            .fill(round < session.roundsCompleted ? AppColors.restPhase : AppColors.backgroundElevated)
                    }
                }
            }
            .frame(height: 12)
            .cornerRadius(6)
            .padding(.horizontal, AppSpacing.md)
        }
    }
    
    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.boltRed)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(AppFonts.h3)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.medium)
    }
}

#Preview {
    SessionDetailView(
        session: Session(
            workoutId: UUID(),
            workoutName: "Classic Tabata",
            totalDuration: 240,
            roundsCompleted: 8,
            roundsTotal: 8,
            workTimeTotal: 160,
            restTimeTotal: 80,
            completionPercentage: 1.0
        ),
        onRepeat: {}
    )
}
