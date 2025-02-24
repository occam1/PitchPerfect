//
//  ExerciseRowView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/9/25.
//
import SwiftUI
struct ExerciseRow: View {
    let exerciseId: String
    @Binding var user: UserData
    @State private var localTurnDuration: Int = 10 // Local state to track changes

    var isLocked: Bool {
        AppDataManager.exercises[exerciseId] ?? true
    }

    var isSelected: Binding<Bool> {
        Binding(
            get: { user.selectedExercises.contains(exerciseId) },
            set: { newValue in
                if newValue {
                    user.selectedExercises.append(exerciseId)
                } else {
                    user.selectedExercises.removeAll { $0 == exerciseId }
                }
                user.save() // ✅ Save immediately after toggle
            }
        )
    }

    var body: some View {
        HStack {
            Button(action: { showDescription(for: exerciseId) }) {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(PlainButtonStyle())

            Text(getExerciseName(for: exerciseId))
                .frame(minWidth: 100, alignment: .leading)

            Spacer()

            // ✅ Stepper now updates immediately
            Stepper(value: $localTurnDuration, in: 1...30, step: 1, onEditingChanged: { _ in
                user.turnDurations[exerciseId] = localTurnDuration
                user.save()
            }) {
                Text("\(localTurnDuration)s")
            }
            .onAppear {
                localTurnDuration = user.turnDurations[exerciseId] ?? 10
            }
            .disabled(isLocked)

            Toggle("", isOn: isSelected)
                .labelsHidden()
                .disabled(isLocked)

            if isLocked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
    }

    private func showDescription(for id: String) {
        print("Show description for: \(id)") // Replace with actual UI pop-up
    }

    private func getExerciseName(for id: String) -> String {
        return id.replacingOccurrences(of: "Exercise", with: "")
    }
}
