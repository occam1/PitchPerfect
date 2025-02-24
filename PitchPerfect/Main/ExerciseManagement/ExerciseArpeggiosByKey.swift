class ExerciseArpeggiosByKey: Exercise {
    private var arpeggioNotes: [(String, Float)] = []  // Filtered notes for the exercise
    override var exerciseName: String {
        return "Arpeggio By Key"
    }
    private var noteIndex: Int = 0

    override func getUsersRange() {
        super.getUsersRange()  // ✅ Get user's range from base class
        sortNotesByFrequency() // ✅ Ensure notes are sorted
    }
    func sortNotesByFrequency() {
        notes.sort { (a: (String, Float), b: (String, Float)) in
            a.1 < b.1  // ✅ Sort by frequency (Float), which is the second element
        }
    }


    override func startExercise() {
        super.startExercise()  // ✅ Ensures user range is loaded
        generateArpeggioNotes()
    }
    
    override func reset() {
            currentIndex = 0
    }

    func generateArpeggioNotes()  {
        print("genArpNotes")
        arpeggioNotes.removeAll() // Start fresh

        for key in AppDataManager.keyNotes.keys {
            guard let keyNotes = AppDataManager.keyNotes[key], keyNotes.count >= 5 else {
                print("Invalid key data for \(key)")
                continue
            }
            print("genArpNotes key \(key)")
            let root = keyNotes[0]  // Root note
            let third = keyNotes[2] // Major third
            let fifth = keyNotes[4] // Perfect fifth
            print("rtf,\(root),\(third),\(fifth)")
            // Find first and last occurrence of root and fifth
            // Find first and last occurrence of root and fifth
            guard let firstIndex = notes.firstIndex(where: { $0.0.dropLast(1) == root }),
                  let lastIndex = notes.lastIndex(where: { $0.0.dropLast(1) == fifth }),
                      lastIndex > firstIndex else {
                    print("Invalid indices for key \(key)")
                    continue
                }
            print("genArpNotes before for indices ,\(firstIndex),\(lastIndex )")
          
            // Process notes from firstIndex to lastIndex
            for index in stride(from: firstIndex, through: lastIndex, by: 12) {
                if index < notes.count { arpeggioNotes.append(notes[index]) } // Root

                let thirdIndex = index + 4
                if thirdIndex <= lastIndex, thirdIndex < notes.count, notes[thirdIndex].0.dropLast(1) == third {
                    arpeggioNotes.append(notes[thirdIndex]) // Third
                }

                let fifthIndex = index + 8
                if fifthIndex <= lastIndex, fifthIndex < notes.count, notes[fifthIndex].0.dropLast(1) == fifth {
                    arpeggioNotes.append(notes[fifthIndex]) // Fifth
                }
                print("genArpNotes ,\(arpeggioNotes) " )
            }
        }
    }

    override func nextNote() -> (note: String, frequency: Float)? {
        currentIndex  = currentIndex + 1
        if currentIndex >= arpeggioNotes.count {
            currentIndex = 0
        }
        if arpeggioNotes.isEmpty { return nil }  // No notes to return
        let next = arpeggioNotes[currentIndex]
        return next
    }
    
    override var description: String {
        return """
        Basic exercise to step through the keys, clockwise on the circle of fifths,
        and for each key, go thru the root, third and fifth in each octave that 
        is in your range.
        """
    }
}
