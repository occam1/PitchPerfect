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
    @State private var localTurnDuration: Int = 10
    @State private var showDescription: Bool = false

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
                user.save()
            }
        )
    }

    var exerciseInstance: Exercise? {
        ExerciseManager.shared.exerciseInstances[exerciseId]
    }

    var body: some View {
        HStack {
            Button(action: { showDescription.toggle() }) {
                Image(systemName: "questionmark.circle")
            }
            .buttonStyle(PlainButtonStyle())
            .popover(isPresented: $showDescription) {
                VStack {
                    Text(getExerciseName(for: exerciseId))
                        .font(.headline)
                        .padding(.top)
                    Text(Exercise.registeredDescriptions[exerciseId] ?? "No description available.")
                        .padding()
                    Button("Close") { showDescription = false }
                        .padding()
                }
                .frame(width: 250)
            }

            Text(getExerciseName(for: exerciseId))
                .frame(minWidth: 100, alignment: .leading)

            Spacer()

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

    private func getExerciseName(for id: String) -> String {
        return id.replacingOccurrences(of: "Exercise", with: "")
    }
}
