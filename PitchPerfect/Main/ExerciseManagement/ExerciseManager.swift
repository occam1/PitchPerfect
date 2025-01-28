//
//  ExerciseManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/27/25.
//
class ExerciseManager {
    static let shared = ExerciseManager()
    private(set) var exercises: [Exercise] = [] // All available exercises
    private var currentExerciseIndex: Int = 0

    init() {
        // Register available exercises
        exercises = [
            ExerciseChromaticStep(),
            //ExerciseDiatonicStepThirds(key: "C"),
            // Add more exercises here
        ]
    }

    func selectNextExercise() {
        currentExerciseIndex = (currentExerciseIndex + 1) % exercises.count
    }

    func currentExercise() -> Exercise {
        return exercises[currentExerciseIndex]
    }

    func resetCurrentExercise() {
        exercises[currentExerciseIndex].reset()
    }
}
