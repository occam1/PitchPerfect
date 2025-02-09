class ExerciseArpeggioByKey: Exercise {
    override var exerciseName: String {
        return "ArpeggioByKey"
    }



    override init() {
        super.init()  // ✅ Call base class initializer
        Exercise.registerExercise(name: "ExerciseArpeggioByKey", instance: self)
   
        // ✅ Generate arpeggio note list based on user's range
        self.notes = generateNoteList()
    }

    /// ✅ Generates an arpeggio note list within user's range
    private func generateNoteList() -> [(String, Float)] {
        var noteSequence: [(String, Float)] = []
        
        let keyOrder = Array(AppDataManager.keyNotes.keys) // Get ordered list of keys
        var keyIndex = 0  // Track key progress

        while noteSequence.count < notes.count {
            let key = keyOrder[keyIndex % keyOrder.count] // Cycle through keys
            if let diatonicNotes = AppDataManager.keyNotes[key] {
                let extendedNotes = getAcceptableRange(diatonicNotes)
                
                for start in 0..<diatonicNotes.count - 2 { // Step through 1-3-5
                    let noteSet = [
                        extendedNotes[start],
                        extendedNotes[start + 2],
                        extendedNotes[start + 4]
                    ]
                    noteSequence.append(contentsOf: noteSet.map { note in
                        (note, AppDataManager.noteFrequencies[note] ?? 0.0)
                    })

                    if noteSequence.count >= notes.count { break }
                }
            }
            keyIndex += 1 // Move to next key
        }

        return noteSequence
    }



    
    override var description: String {
        return """
        basic exercise to step thru the diatonic notes and for each note follow it with the first, third, and fifth of the chord that starts
                on that diatonic note,   the first note is followed by the third and fifth,  the second is followed by the fourth and sixth,
                the third is followed by the fifth and the seventh , the fourth, sixth, octave, the fifth, seventh and ninth (second of the next octave.
                The sixth, octave and 3rd of the second octave etc until the 3rd note of the set exceeds your highest note 
        """
    }
}
