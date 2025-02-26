//
//  Untitled.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/25/25.
//
class ExerciseScaleSteps: Exercise {
    static let shared = ExerciseScaleSteps()

    override var exerciseName: String {
        return "Scale Steps"
    }

    override init() {
        super.init()
        print("✅ ExerciseScaleSteps initialized")
        Exercise.registerExercise(name: "ExerciseScaleSteps", instance: self)
    }

    override func reset() {
        print("ESS reset")
        currentIndex = 0
    }

    override func getUsersRange() {
        super.getUsersRange()  // ✅ Load user's vocal range
        sortNotesByFrequency() // ✅ Ensure notes are sorted
        generateScaleSteps()   // ✅ Create the sequence of notes
    }
  
func sortNotesByFrequency() {
    exerciseNoteFrequencies.sort { (a: (String, Float), b: (String, Float)) in
        a.1 < b.1  // ✅ Sort by frequency (Float), which is the second element
    }
}


    private func generateScaleSteps() {
        var expandedNotes: [(String, Float)] = []
        var lastNoteAppended: String = " " // ✅ Track last added note

        for key in AppDataManager.circleOfFifths {
            let lookupKey = AppDataManager.enharmonics[key] ?? key
            guard let keyNotes = AppDataManager.keyNotes[key], keyNotes.count >= 7 else {
                print("Invalid key data for \(key)  \(lookupKey)")
                continue
            }

            let originalRoot = keyNotes[0] // ✅ Root
            let originalOctave = keyNotes[0] // ✅ Octave is the same pitch class as root
            let rootLookup = AppDataManager.enharmonics[originalRoot] ?? originalRoot
            let octaveLookup = AppDataManager.enharmonics[originalOctave] ?? originalOctave

            // ✅ Find first and last occurrence of root and octave
            guard let firstIndex = exerciseNoteFrequencies.firstIndex(where: { $0.0.dropLast(1) == rootLookup }),
                  let lastIndex = exerciseNoteFrequencies.lastIndex(where: { $0.0.dropLast(1) == octaveLookup }),
                  lastIndex > firstIndex else {
                print("Invalid indices for key \(key)")
                continue
            }

            for index in stride(from: firstIndex, through: lastIndex, by: 12) {
                var fullScaleAvailable = true

                // ✅ Add the root only if it's not the same as the last appended note
                if lastNoteAppended != exerciseNoteFrequencies[index].0 {
                    expandedNotes.append(exerciseNoteFrequencies[index])
                    lastNoteAppended = exerciseNoteFrequencies[index].0
                }

                let scaleSteps = [2, 4, 5, 7, 9, 11, 12] // ✅ M2, M3, P4, P5, M6, M7, Octave

                for step in scaleSteps {
                    let stepIndex = index + step
                    if stepIndex <= lastIndex, stepIndex < exerciseNoteFrequencies.count {
                        let storedNote = exerciseNoteFrequencies[stepIndex].0

                        if lastNoteAppended != storedNote { // ✅ Prevent duplicates
                            expandedNotes.append(exerciseNoteFrequencies[stepIndex])
                            lastNoteAppended = storedNote
                            print("Root: \(originalRoot), Scale Note: \(storedNote)")
                        }
                    } else {
                        fullScaleAvailable = false
                        break // ✅ Stop if full scale is not in range
                    }
                }

                if !fullScaleAvailable {
                    break // ✅ Stop generating scales if the full octave is not in range
                }
            }
        }

        exerciseNoteFrequencies = expandedNotes
        print("✅ Generated Scale Steps: \(expandedNotes)")
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
        print("ESS isLast: \(isLast)")
        let next = exerciseNoteFrequencies[currentIndex]
        currentIndex += incrementer

        return (next, isLast)
    }

    public override func getDescription() -> String {
        return description
    }

    override var description: String {
        return """
        This exercise follows a full scale pattern, playing all scale degrees: Root, M2, M3, P4, P5, M6, M7, and the octave.
        The next scale is only played if the full octave is within the singer's range.
        This exercise helps develop pitch accuracy and interval recognition.
        """
    }
}
