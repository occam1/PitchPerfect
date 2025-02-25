//
//  ExercisePerfectFifthsChromaticStep.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/24/25.
//
class ExercisePerfectFifthsChromaticStep: Exercise {
    static let shared = ExercisePerfectFifthsChromaticStep()

    override var exerciseName: String {
        return "Perfect Fifths Chromatic Step"
    }

    override init() {
        super.init()
        print("✅ ExercisePerfectFifthsChromaticStep initialized")
        Exercise.registerExercise(name: "ExercisePerfectFifthsChromaticStep", instance: self)
    }

    override func reset() {
        print("EPFCS reset")
        currentIndex = 0
        incrementer = 1
    }

    override func getUsersRange() {
        super.getUsersRange()  // ✅ Get user's range from base class
        sortNotesByFrequency() // ✅ Ensure notes are sorted
        addPerfectFifths()      // ✅ Insert major thirds between notes
    }
    func sortNotesByFrequency() {
        exerciseNoteFrequencies.sort { (a: (String, Float), b: (String, Float)) in
            a.1 < b.1  // ✅ Sort by frequency (Float), which is the second element
        }
    }
    private func addPerfectFifths() {
        var expandedNotes: [(String, Float)] = []
        
        for (note, frequency) in exerciseNoteFrequencies {
            expandedNotes.append((note, frequency)) // ✅ Add the original note
            print("note , \(note)")
            // ✅ Get the major third note using getInterval()
            if let perfectFifthNote = getInterval(note: note, semitones: 7) {
                expandedNotes.append(perfectFifthNote)
               print(" perfectFifthNote, \(perfectFifthNote)")
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
        This exercise follows the chromatic step pattern but inserts a perfect fifth (7 semitones up) between each note. 
        It helps train pitch jumps and interval recognition while maintaining the singer's range.
        """
    }
}

