import SwiftUI

struct WorkoutsView: View {
    @StateObject private var storage = StorageService.shared
    @Binding var selectedWorkout: Workout?
    
    @State private var showEditor = false
    @State private var editingWorkout: Workout?
    @State private var showDeleteConfirmation = false
    @State private var workoutToDelete: Workout?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary
                    .ignoresSafeArea()
                
                if storage.customWorkouts.isEmpty {
                    EmptyWorkoutsView {
                        editingWorkout = nil
                        showEditor = true
                    }
                } else {
                    workoutList
                }
            }
            .navigationTitle("My Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editingWorkout = nil
                        showEditor = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.boltRed)
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                WorkoutEditorView(workout: editingWorkout) { workout in
                    if editingWorkout != nil {
                        storage.updateWorkout(workout)
                    } else {
                        storage.addWorkout(workout)
                    }
                }
            }
            .alert("Delete Workout?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let workout = workoutToDelete {
                        storage.deleteWorkout(workout)
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private var workoutList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(storage.customWorkouts) { workout in
                    WorkoutCardView(workout: workout) {
                        startWorkout(workout)
                    }
                    .contextMenu {
                        Button {
                            editingWorkout = workout
                            showEditor = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button {
                            duplicateWorkout(workout)
                        } label: {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        
                        Button(role: .destructive) {
                            workoutToDelete = workout
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            workoutToDelete = workout
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
        }
    }
    
    private func startWorkout(_ workout: Workout) {
        storage.markWorkoutAsUsed(workout)
        selectedWorkout = workout
    }
    
    private func duplicateWorkout(_ workout: Workout) {
        var newWorkout = workout
        newWorkout = Workout(
            name: "\(workout.name) Copy",
            workDuration: workout.workDuration,
            restDuration: workout.restDuration,
            rounds: workout.rounds,
            warmupDuration: workout.warmupDuration,
            cooldownDuration: workout.cooldownDuration,
            countdownDuration: workout.countdownDuration
        )
        storage.addWorkout(newWorkout)
    }
}

struct EmptyWorkoutsView: View {
    let onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image("empty_workouts")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No Custom Workouts Yet")
                    .font(AppFonts.h3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Create your first interval sequence")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            PrimaryButton(title: "Create Workout", action: onCreate)
                .frame(maxWidth: 200)
        }
        .padding(AppSpacing.lg)
    }
}

struct WorkoutCardView: View {
    let workout: Workout
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticService.shared.lightImpact()
            action()
        }) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(workout.name)
                        .font(AppFonts.h3)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: AppSpacing.sm) {
                        Text(workout.formattedDuration)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("•")
                            .foregroundColor(AppColors.textMuted)
                        
                        Text(workout.intervalSummary)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    if let lastUsed = workout.lastUsedAt {
                        Text("Last used: \(lastUsed, style: .relative) ago")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)
                    }
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.boltRed)
            }
            .padding(AppSpacing.md)
            .background(AppColors.backgroundCard)
            .cornerRadius(AppCorners.large)
        }
    }
}

#Preview {
    WorkoutsView(selectedWorkout: .constant(nil))
}
