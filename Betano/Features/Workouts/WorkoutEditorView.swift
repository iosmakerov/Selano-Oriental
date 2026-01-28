import SwiftUI

struct WorkoutEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    let workout: Workout?
    let onSave: (Workout) -> Void
    
    @State private var name: String = ""
    @State private var workDuration: Int = 30
    @State private var restDuration: Int = 15
    @State private var rounds: Int = 8
    @State private var warmupDuration: Int = 0
    @State private var cooldownDuration: Int = 0
    @State private var countdownDuration: Int = 3
    @State private var showAdvanced = false
    @State private var showDiscardAlert = false
    
    private var isEditing: Bool { workout != nil }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        name.count <= 30 &&
        totalDuration <= 3600 // 60 minutes max
    }
    
    private var totalDuration: Int {
        warmupDuration + (workDuration + restDuration) * rounds + cooldownDuration
    }
    
    private var formattedTotal: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var isDirty: Bool {
        if let workout = workout {
            return name != workout.name ||
                   workDuration != workout.workDuration ||
                   restDuration != workout.restDuration ||
                   rounds != workout.rounds
        }
        return !name.isEmpty
    }
    
    init(workout: Workout?, onSave: @escaping (Workout) -> Void) {
        self.workout = workout
        self.onSave = onSave
        
        if let workout = workout {
            _name = State(initialValue: workout.name)
            _workDuration = State(initialValue: workout.workDuration)
            _restDuration = State(initialValue: workout.restDuration)
            _rounds = State(initialValue: workout.rounds)
            _warmupDuration = State(initialValue: workout.warmupDuration)
            _cooldownDuration = State(initialValue: workout.cooldownDuration)
            _countdownDuration = State(initialValue: workout.countdownDuration)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Name Field
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Workout Name")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            TextField("", text: $name)
                                .font(AppFonts.bodyLarge)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(AppSpacing.md)
                                .background(AppColors.backgroundCard)
                                .cornerRadius(AppCorners.medium)
                                .overlay(
                                    Text("Workout Name")
                                        .font(AppFonts.bodyLarge)
                                        .foregroundColor(AppColors.textMuted)
                                        .padding(.leading, AppSpacing.md)
                                        .opacity(name.isEmpty ? 1 : 0),
                                    alignment: .leading
                                )
                        }
                        
                        // Interval Configuration
                        VStack(spacing: AppSpacing.md) {
                            DurationStepper(
                                title: "Work",
                                value: $workDuration,
                                range: 5...300,
                                step: 5,
                                accentColor: AppColors.boltRed
                            )
                            
                            DurationStepper(
                                title: "Rest",
                                value: $restDuration,
                                range: 5...300,
                                step: 5,
                                accentColor: AppColors.restPhase
                            )
                            
                            RoundsStepper(
                                title: "Rounds",
                                value: $rounds,
                                range: 1...50
                            )
                        }
                        
                        // Preview
                        VStack(spacing: AppSpacing.sm) {
                            Text("Total Duration")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text(formattedTotal)
                                .font(AppFonts.timerDisplayMedium)
                                .foregroundColor(AppColors.textPrimary)
                            
                            // Timeline Preview
                            TimelinePreview(
                                workDuration: workDuration,
                                restDuration: restDuration,
                                rounds: rounds
                            )
                        }
                        .padding(AppSpacing.lg)
                        .background(AppColors.backgroundCard)
                        .cornerRadius(AppCorners.large)
                        
                        // Advanced Options
                        DisclosureGroup(isExpanded: $showAdvanced) {
                            VStack(spacing: AppSpacing.md) {
                                DurationStepper(
                                    title: "Warm-up",
                                    value: $warmupDuration,
                                    range: 0...60,
                                    step: 5,
                                    accentColor: AppColors.textSecondary
                                )
                                
                                DurationStepper(
                                    title: "Cool-down",
                                    value: $cooldownDuration,
                                    range: 0...60,
                                    step: 5,
                                    accentColor: AppColors.textSecondary
                                )
                                
                                CountdownPicker(value: $countdownDuration)
                            }
                            .padding(.top, AppSpacing.md)
                        } label: {
                            Text("Advanced Options")
                                .font(AppFonts.h3)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .tint(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.md)
                }
            }
            .navigationTitle(isEditing ? "Edit Workout" : "New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if isDirty {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .foregroundColor(isValid ? AppColors.boltRed : AppColors.textMuted)
                    .disabled(!isValid)
                }
            }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Keep Editing", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            }
        }
    }
    
    private func saveWorkout() {
        let newWorkout = Workout(
            id: workout?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            workDuration: workDuration,
            restDuration: restDuration,
            rounds: rounds,
            warmupDuration: warmupDuration,
            cooldownDuration: cooldownDuration,
            countdownDuration: countdownDuration,
            createdAt: workout?.createdAt ?? Date(),
            lastUsedAt: workout?.lastUsedAt
        )
        onSave(newWorkout)
        dismiss()
    }
}

// MARK: - Duration Stepper
struct DurationStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let accentColor: Color
    
    private var formattedValue: String {
        let minutes = value / 60
        let seconds = value % 60
        if minutes > 0 {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
        return "\(seconds)s"
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            HStack(spacing: AppSpacing.md) {
                Button {
                    if value - step >= range.lowerBound {
                        value -= step
                        HapticService.shared.selection()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value > range.lowerBound ? accentColor : AppColors.textMuted)
                }
                .disabled(value <= range.lowerBound)
                
                Text(formattedValue)
                    .font(AppFonts.h2)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 60)
                
                Button {
                    if value + step <= range.upperBound {
                        value += step
                        HapticService.shared.selection()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value < range.upperBound ? accentColor : AppColors.textMuted)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.medium)
    }
}

// MARK: - Rounds Stepper
struct RoundsStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            HStack(spacing: AppSpacing.md) {
                Button {
                    if value - 1 >= range.lowerBound {
                        value -= 1
                        HapticService.shared.selection()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value > range.lowerBound ? AppColors.boltRed : AppColors.textMuted)
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(AppFonts.h2)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 60)
                
                Button {
                    if value + 1 <= range.upperBound {
                        value += 1
                        HapticService.shared.selection()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(value < range.upperBound ? AppColors.boltRed : AppColors.textMuted)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.medium)
    }
}

// MARK: - Timeline Preview
struct TimelinePreview: View {
    let workDuration: Int
    let restDuration: Int
    let rounds: Int
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let intervalWidth = totalWidth / CGFloat(rounds)
            let workRatio = CGFloat(workDuration) / CGFloat(workDuration + restDuration)
            
            HStack(spacing: 2) {
                ForEach(0..<min(rounds, 20), id: \.self) { _ in
                    HStack(spacing: 1) {
                        Rectangle()
                            .fill(AppColors.workPhase)
                            .frame(width: max((intervalWidth - 3) * workRatio, 2))
                        
                        Rectangle()
                            .fill(AppColors.restPhase)
                            .frame(width: max((intervalWidth - 3) * (1 - workRatio), 2))
                    }
                }
            }
        }
        .frame(height: 8)
        .cornerRadius(4)
    }
}

// MARK: - Countdown Picker
struct CountdownPicker: View {
    @Binding var value: Int
    
    let options = [3, 5, 10]
    
    var body: some View {
        HStack {
            Text("Countdown")
                .font(AppFonts.h3)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(options, id: \.self) { option in
                    Button {
                        value = option
                        HapticService.shared.selection()
                    } label: {
                        Text("\(option)s")
                            .font(AppFonts.button)
                            .foregroundColor(value == option ? .white : AppColors.textSecondary)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                            .background(value == option ? AppColors.boltRed : AppColors.backgroundElevated)
                            .cornerRadius(AppCorners.small)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.backgroundCard)
        .cornerRadius(AppCorners.medium)
    }
}

#Preview {
    WorkoutEditorView(workout: nil) { _ in }
}
