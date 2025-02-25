//
//  ExerciseMajorThirdsChromaticStep.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/24/25.
//
class ExerciseMajorThirdsChromaticStep: Exercise {
    static let shared = ExerciseMajorThirdsChromaticStep()

    override var exerciseName: String {
        return "Major Thirds Chromatic Step"
    }

    override init() {
        super.init()
        print("✅ ExerciseMajorThirdsChromaticStep initialized")
        Exercise.registerExercise(name: "ExerciseMajorThirdsChromaticStep", instance: self)
    }

    override func reset() {
        print("EMTCS reset")
        currentIndex = 0
        incrementer = 1
    }

    override func getUsersRange() {
        super.getUsersRange()  // ✅ Get user's range from base class
        sortNotesByFrequency() // ✅ Ensure notes are sorted
        addMajorThirds()      // ✅ Insert major thirds between notes
    }
    func sortNotesByFrequency() {
        exerciseNoteFrequencies.sort { (a: (String, Float), b: (String, Float)) in
            a.1 < b.1  // ✅ Sort by frequency (Float), which is the second element
        }
    }
    private func addMajorThirds() {
        var expandedNotes: [(String, Float)] = []
        
        for (note, frequency) in exerciseNoteFrequencies {
            expandedNotes.append((note, frequency)) // ✅ Add the original note
            print("note , \(note)")
            // ✅ Get the major third note using getInterval()
            if let majorThirdNote = getInterval(note: note, semitones: 4) {
                expandedNotes.append(majorThirdNote)
               print(" majorThirdNote, \(majorThirdNote)")
            }
        }
        
        exerciseNoteFrequencies = expandedNotes // ✅ Replace with expanded list
        print("expandedNotes , \(expandedNotes)")
        print("exerciseNoteFrequencies , \(exerciseNoteFrequencies)")
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
        print("EMTCS isLast: \(isLast)")
        let next = exerciseNoteFrequencies[currentIndex]
        currentIndex += incrementer

        return (next, isLast)
    }

    public override func getDescription() -> String {
        return description
    }

    override var description: String {
        return """
        This exercise follows the chromatic step pattern but inserts a major third (4 semitones up) between each note. 
        It helps train pitch jumps and interval recognition while maintaining the singer's range.
        """
    }
}
