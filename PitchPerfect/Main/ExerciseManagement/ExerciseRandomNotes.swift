//
//  ExerciseRandomNotes.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/24/25.
//
class ExerciseRandomNotes: Exercise {
    static let shared = ExerciseRandomNotes()

    override var exerciseName: String {
        return "Random Chromatic Step"
    }

    override init() {
        super.init()
        print("✅ ExerciseRandomNotes initialized")
        Exercise.registerExercise(name: "ExerciseRandomNotes", instance: self)
    }

    override func reset() {
        print("ERN reset")
        currentIndex = 0
        incrementer = 1
        shuffleNotes() // ✅ Reshuffle notes when resetting
    }

    override func getUsersRange() {
        super.getUsersRange() // ✅ Load user's vocal range
        shuffleNotes() // ✅ Randomize notes
    }

    private func shuffleNotes() {
        print("🔀 Shuffling notes for Random Notes")
        exerciseNoteFrequencies.shuffle() // ✅ Efficient in-place shuffle
    }

    override func nextNote() -> ((note: String, frequency: Float)?, isLast: Bool) {
        if currentIndex >= exerciseNoteFrequencies.count - 1 {
            currentIndex = exerciseNoteFrequencies.count - 1
            incrementer = -1  // ✅ Reverse direction
        }
        if currentIndex == 0 {
            incrementer = 1
        }
        guard !exerciseNoteFrequencies.isEmpty else { return (nil, false) }
        let isLast = (currentIndex == 1 && incrementer == -1) // ✅ Detect last note
        print("ERCS isLast: \(isLast)")
        let next = exerciseNoteFrequencies[currentIndex]
        currentIndex += incrementer

        return (next, isLast)
    }

    public override func getDescription() -> String {
        return description
    }

    override var description: String {
        return """
        This exercise follows the chromatic step pattern but randomly shuffles the notes within the user's range.
        This exercise will help improve vocal agility by requiring quick, unpredictable pitch changes.
        """
    }
}
