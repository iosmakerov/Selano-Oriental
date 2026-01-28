import SwiftUI

struct HistoryView: View {
    @StateObject private var storage = StorageService.shared
    @State private var selectedSession: Session?
    @State private var showDeleteConfirmation = false
    @State private var sessionToDelete: Session?
    
    @Binding var selectedWorkout: Workout?
    @Binding var showActiveSession: Bool
    
    var groupedSessions: [(String, [Session])] {
        Session.groupByDate(storage.sessionHistory)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                if storage.sessionHistory.isEmpty {
                    EmptyHistoryView()
                } else {
                    historyContent
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedSession) { session in
                SessionDetailView(session: session) {
                    repeatSession(session)
                }
            }
            .alert("Delete Session?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let session = sessionToDelete {
                        storage.deleteSession(session)
                    }
                }
            }
        }
    }
    
    private var historyContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Stats Card
                StatsCardView()
                    .padding(.horizontal, AppSpacing.md)
                
                // Session List
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(groupedSessions, id: \.0) { group in
                        Section {
                            ForEach(group.1) { session in
                                SessionRowView(session: session)
                                    .onTapGesture {
                                        selectedSession = session
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            sessionToDelete = session
                                            showDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Text(group.0)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.top, AppSpacing.md)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.md)
            }
            .padding(.top, AppSpacing.md)
        }
    }
    
    private func repeatSession(_ session: Session) {
        // Find workout by ID or create from session
        if let workout = storage.customWorkouts.first(where: { $0.id == session.workoutId }) {
            selectedWorkout = workout
        } else if let preset = Workout.presets.first(where: { $0.id == session.workoutId }) {
            selectedWorkout = preset
        } else {
            // Create a workout from session data
            selectedWorkout = Workout(
                id: session.workoutId,
                name: session.workoutName,
                workDuration: session.workTimeTotal / session.roundsTotal,
                restDuration: session.restTimeTotal / max(session.roundsTotal - 1, 1),
                rounds: session.roundsTotal
            )
        }
        showActiveSession = true
    }
}

// MARK: - Empty State
struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image("empty_history")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No Sessions Yet")
                    .font(AppFonts.h3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Complete your first workout to see it here")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.lg)
    }
}

// MARK: - Stats Card
struct StatsCardView: View {
    @StateObject private var storage = StorageService.shared
    
    var stats: (sessions: Int, totalTime: Int, streak: Int) {
        storage.weeklyStats
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text("This Week")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
            
            HStack(spacing: AppSpacing.xl) {
                StatItem(value: "\(stats.sessions)", label: "Sessions")
                StatItem(value: formatTime(stats.totalTime), label: "Active Time")
                StatItem(value: "\(stats.streak)", label: "Day Streak")
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppColors.boltRed.opacity(0.2), AppColors.backgroundCard],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppCorners.large)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFonts.h2)
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Row
struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Completion Ring
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundElevated, lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: session.completionPercentage)
                    .stroke(
                        session.isCompleted ? AppColors.success : AppColors.warning,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(session.completionPercentage * 100))%")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(session.workoutName)
                    .font(AppFonts.h3)
                    .foregroundColor(session.isCompleted ? AppColors.boltRed : AppColors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: AppSpacing.sm) {
                    Text(session.formattedDuration)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("•")
                        .foregroundColor(AppColors.textMuted)
                    
                    Text("\(session.roundsCompleted)/\(session.roundsTotal) rounds")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            Text(session.startedAt, style: .time)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.medium)
    }
}

#Preview {
    HistoryView(selectedWorkout: .constant(nil), showActiveSession: .constant(false))
}
