import SwiftUI

struct ActiveSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SessionViewModel
    @State private var showStopConfirmation = false
    
    init(workout: Workout) {
        _viewModel = StateObject(wrappedValue: SessionViewModel(workout: workout))
    }
    
    var body: some View {
        Group {
            if viewModel.isCompleted {
                CompletedView(viewModel: viewModel, onDismiss: { dismiss() })
            } else if viewModel.isPaused {
                pausedOverlay
            } else {
                activeSessionContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            backgroundView
                .ignoresSafeArea()
        )
        .onAppear {
            viewModel.start()
        }
        .alert("End Workout?", isPresented: $showStopConfirmation) {
            Button("Continue", role: .cancel) {}
            Button("End", role: .destructive) {
                viewModel.stop()
                dismiss()
            }
        } message: {
            Text("Your progress will be saved.")
        }
    }
    
    // MARK: - Background
    @ViewBuilder
    private var backgroundView: some View {
        GeometryReader { geometry in
            switch viewModel.currentPhase {
            case .work:
                ZStack {
                    Image("phase_work")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    
                    LinearGradient(
                        colors: [AppColors.boltRedDark.opacity(0.8), AppColors.backgroundPrimary.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            case .rest, .cooldown:
                ZStack {
                    Image("phase_rest")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                    
                    LinearGradient(
                        colors: [AppColors.restPhase.opacity(0.3), AppColors.backgroundPrimary.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            default:
                AppColors.backgroundPrimary
            }
        }
    }
    
    // MARK: - Active Content
    private var activeSessionContent: some View {
        VStack(spacing: 0) {
            // Top Bar
            topBar
            
            Spacer()
            
            // Motivational Text
            if viewModel.showMotivation {
                Text(viewModel.motivationalText)
                    .font(AppFonts.h2)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.boltRed.opacity(0.9))
                    .cornerRadius(AppCorners.medium)
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.3), value: viewModel.showMotivation)
            }
            
            Spacer()
            
            // Timer Display
            timerDisplay
            
            Spacer()
            
            // Phase Indicator
            phaseIndicator
                .padding(.bottom, AppSpacing.lg)
            
            // Next Preview
            if !viewModel.nextPhaseText.isEmpty {
                Text(viewModel.nextPhaseText)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.bottom, AppSpacing.lg)
            }
            
            // Control Bar
            controlBar
                .padding(.bottom, AppSpacing.xl)
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button {
                viewModel.pause()
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.backgroundCard.opacity(0.8))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text(viewModel.roundText)
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button {
                showStopConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.backgroundCard.opacity(0.8))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.md)
    }
    
    // MARK: - Timer Display
    private var timerDisplay: some View {
        VStack(spacing: AppSpacing.md) {
            // Circular Progress
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundElevated, lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        phaseColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: viewModel.progress)
                
                VStack(spacing: AppSpacing.sm) {
                    Text(formatTime(viewModel.timeRemaining))
                        .font(AppFonts.timerDisplay)
                        .foregroundColor(AppColors.textPrimary)
                        .monospacedDigit()
                    
                    Text(viewModel.currentPhase.displayName)
                        .font(AppFonts.phaseLabel)
                        .foregroundColor(phaseColor)
                }
            }
            .frame(width: 280, height: 280)
        }
    }
    
    private var phaseColor: Color {
        switch viewModel.currentPhase {
        case .work: return AppColors.workPhase
        case .rest, .cooldown: return AppColors.restPhase
        default: return AppColors.textSecondary
        }
    }
    
    // MARK: - Phase Indicator
    private var phaseIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<viewModel.workout.rounds, id: \.self) { round in
                RoundIndicator(
                    round: round + 1,
                    currentRound: viewModel.currentRound,
                    currentPhase: viewModel.currentPhase
                )
            }
        }
        .padding(.horizontal, AppSpacing.md)
    }
    
    // MARK: - Control Bar
    private var controlBar: some View {
        HStack(spacing: AppSpacing.xl) {
            Spacer()
            
            // Main Pause Button
            Button {
                viewModel.pause()
            } label: {
                Image(systemName: "pause.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(AppColors.boltRed)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Skip Button
            Button {
                viewModel.skipPhase()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 50, height: 50)
                    .background(AppColors.backgroundCard)
                    .clipShape(Circle())
            }
            
            Spacer()
        }
    }
    
    // MARK: - Paused Overlay
    private var pausedOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                Text("PAUSED")
                    .font(AppFonts.h1)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(viewModel.roundText)
                    .font(AppFonts.bodyLarge)
                    .foregroundColor(AppColors.textSecondary)
                
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton(title: "Resume") {
                        viewModel.resume()
                    }
                    
                    SecondaryButton(title: "End Workout") {
                        viewModel.stop()
                        dismiss()
                    }
                }
                .padding(.horizontal, AppSpacing.xxl)
            }
        }
    }
    
    // MARK: - Helpers
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        if mins > 0 {
            return String(format: "%d:%02d", mins, secs)
        }
        return "\(secs)"
    }
}

// MARK: - Round Indicator
struct RoundIndicator: View {
    let round: Int
    let currentRound: Int
    let currentPhase: SessionPhase
    
    var body: some View {
        HStack(spacing: 2) {
            Rectangle()
                .fill(workColor)
                .frame(height: 6)
            
            Rectangle()
                .fill(restColor)
                .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(3)
    }
    
    private var workColor: Color {
        if round < currentRound {
            return AppColors.workPhase
        } else if round == currentRound && currentPhase == .work {
            return AppColors.workPhase.opacity(0.5)
        }
        return AppColors.backgroundElevated
    }
    
    private var restColor: Color {
        if round < currentRound {
            return AppColors.restPhase
        } else if round == currentRound && currentPhase == .rest {
            return AppColors.restPhase.opacity(0.5)
        }
        return AppColors.backgroundElevated
    }
}

// MARK: - Completed View
struct CompletedView: View {
    @ObservedObject var viewModel: SessionViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            Image("session_complete")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
            
            VStack(spacing: AppSpacing.sm) {
                Text("Great Work!")
                    .font(AppFonts.h1)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(viewModel.workout.name)
                    .font(AppFonts.bodyLarge)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Stats Card
            VStack(spacing: AppSpacing.md) {
                StatRow(title: "Duration", value: formatDuration(viewModel.totalElapsedTime))
                StatRow(title: "Rounds", value: "\(viewModel.workout.rounds)")
                StatRow(title: "Work Time", value: formatDuration(viewModel.workout.workDuration * viewModel.workout.rounds))
                StatRow(title: "Calories", value: "\(viewModel.estimatedCalories) kcal")
            }
            .padding(AppSpacing.lg)
            .background(AppColors.backgroundCard)
            .cornerRadius(AppCorners.large)
            .padding(.horizontal, AppSpacing.lg)
            
            Spacer()
            
            PrimaryButton(title: "Done", action: onDismiss)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColors.backgroundPrimary)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
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

#Preview {
    ActiveSessionView(workout: Workout.tabata)
}
