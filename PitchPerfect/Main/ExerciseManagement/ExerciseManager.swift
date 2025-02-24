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
        print("🔄 loadUserExercises called for user: \(user.userName)")
        exerciseInstances.removeAll()
        selectedExercises.removeAll()

        for (exerciseName, isLocked) in AppDataManager.exercises {
            if !isLocked, user.selectedExercises.contains(exerciseName) {
                selectedExercises.append(exerciseName)
                print("✅ Selected: \(exerciseName)")
                // ✅ Retrieve from the dynamic registry
                           if let exerciseInstance = Exercise.registeredExercises[exerciseName] {
                               exerciseInstances[exerciseName] = exerciseInstance
                               print("✅ Added \(exerciseName) to exerciseInstances")
                           } else {
                               print("⚠️ Warning: \(exerciseName) is in selectedExercises but not found in registeredExercises")
                           }
            }
        }

        // ✅ Automatically select "ExerciseArpeggiosByKey" if no exercises are selected
        if selectedExercises.isEmpty {
            let defaultExercise = "ExerciseArpeggiosByKey"
            print("⚠️ No exercises selected, defaulting to \(defaultExercise)")

            if let defaultInstance = Exercise.registeredExercises[defaultExercise] {
                selectedExercises.append(defaultExercise)
                exerciseInstances[defaultExercise] = defaultInstance
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
        
        let exercise = exerciseInstances[selectedExercises[currentExerciseIndex]]
        exercise?.reset() // ✅ Reset before returning to ensure it's always ready
        
        return exercise
    }

    func resetCurrentExercise() {
        currentExercise()?.reset()
    }
}
