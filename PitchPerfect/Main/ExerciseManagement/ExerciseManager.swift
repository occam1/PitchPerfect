//
//  ExerciseManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/27/25.
//
import Foundation
class ExerciseManager {
    static let shared = ExerciseManager()
    
    private var exerciseInstances: [String: Exercise] = [:]
    private var selectedExercises: [String] = []
    private var currentExerciseIndex = 0

    private init() {}

    func loadUserExercises(for user: UserData) {
        exerciseInstances.removeAll()
        selectedExercises.removeAll()

        for (exerciseName, isLocked) in AppDataManager.exercises {
            if !isLocked, user.selectedExercises.contains(exerciseName) {
                selectedExercises.append(exerciseName)

                // ✅ Retrieve from the dynamic registry
                if let exerciseInstance = Exercise.registeredExercises[exerciseName] {
                    exerciseInstances[exerciseName] = exerciseInstance
                }
            }
        }

        print("✅ Loaded \(selectedExercises.count) exercises for \(user.userName).")
    }

    func selectNextExercise() {
        guard !selectedExercises.isEmpty else { return }
        currentExerciseIndex = (currentExerciseIndex + 1) % selectedExercises.count
    }

    func currentExercise() -> Exercise? {
        guard !selectedExercises.isEmpty else { return nil }
        return exerciseInstances[selectedExercises[currentExerciseIndex]]
    }

    func resetCurrentExercise() {
        currentExercise()?.reset()
    }
}
