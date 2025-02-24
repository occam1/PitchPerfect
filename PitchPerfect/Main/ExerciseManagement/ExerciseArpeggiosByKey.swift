class ExerciseArpeggiosByKey: Exercise {
    private var arpeggioNotes: [(String, Float)] = []  // Filtered notes for the exercise
    override var exerciseName: String {
        return "Arpeggio By Key"
    }
    private var noteIndex: Int = 0
    override init() {
        super.init()
    }
    override func getUsersRange() {
        super.getUsersRange()  // ✅ Get user's range from base class
        sortNotesByFrequency() // ✅ Ensure notes are sorted
    }
    
    func sortNotesByFrequency() {
        exerciseNoteFrequencies.sort { (a: (String, Float), b: (String, Float)) in
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

    func generateArpeggioNotes() {
        arpeggioNotes.removeAll() // Start fresh

        for key in AppDataManager.circleOfFifths {
            let lookupKey = AppDataManager.enharmonics[key] ?? key
            guard let keyNotes = AppDataManager.keyNotes[key], keyNotes.count >= 5 else {
                print("Invalid key data for \(key)  \(lookupKey)")
                continue
            }
           //print("key and keyNotes[0]: \(key), \(keyNotes[0]) ")
            // Store original note names (could be flats)
            let originalRoot = keyNotes[0]
            let originalThird = keyNotes[2]
            let originalFifth = keyNotes[4]

            // Convert flats to sharps for lookup
            let rootLookup = AppDataManager.enharmonics[originalRoot] ?? originalRoot
            let thirdLookup = AppDataManager.enharmonics[originalThird] ?? originalThird
            let fifthLookup = AppDataManager.enharmonics[originalFifth] ?? originalFifth
            //print("rootLookup and fifthLookup: \(rootLookup), \(fifthLookup) ")
            // Find first and last occurrence of root and fifth
            guard let firstIndex = exerciseNoteFrequencies.firstIndex(where: { $0.0.dropLast(1) == rootLookup }),
                  let lastIndex = exerciseNoteFrequencies.lastIndex(where: { $0.0.dropLast(1) == fifthLookup }),
                  lastIndex > firstIndex else {
                print("Invalid indices for key \(key)")
                continue
            }

            // Process notes from firstIndex to lastIndex
            for index in stride(from: firstIndex, through: lastIndex, by: 12) {
                       if index < exerciseNoteFrequencies.count {
                           let noteOctave = exerciseNoteFrequencies[index].0 // Extract octave from matched note
                           let storedNote = originalRoot + noteOctave.suffix(1) // Append the octave to the original flat name
                           arpeggioNotes.append((storedNote, exerciseNoteFrequencies[index].1)) // Store original flat name + octave
                       }

                       let thirdIndex = index + 4
                       if thirdIndex <= lastIndex, thirdIndex < exerciseNoteFrequencies.count,
                          exerciseNoteFrequencies[thirdIndex].0.dropLast(1) == thirdLookup {
                           let noteOctave = exerciseNoteFrequencies[thirdIndex].0
                           let storedNote = originalThird + noteOctave.suffix(1)
                           arpeggioNotes.append((storedNote, exerciseNoteFrequencies[thirdIndex].1))
                       }

                       let fifthIndex = index + 7
                       if fifthIndex <= lastIndex, fifthIndex < exerciseNoteFrequencies.count,
                          exerciseNoteFrequencies[fifthIndex].0.dropLast(1) == fifthLookup {
                           let noteOctave = exerciseNoteFrequencies[fifthIndex].0
                           let storedNote = originalFifth + noteOctave.suffix(1)
                           arpeggioNotes.append((storedNote, exerciseNoteFrequencies[fifthIndex].1))
                       }
            }
        }
        //print("arpeggioNotes: \(arpeggioNotes)")
    }
    override func nextNote() -> ((note: String, frequency: Float)?, isLast:Bool)  {
        
        if currentIndex >= arpeggioNotes.count {
            currentIndex = 0
        }
        if arpeggioNotes.isEmpty { return (nil, false) }  // No notes to return
        
       //guard !exerciseNoteFrequencies.isEmpty else {
       //    var emptyNote : (String,Float) = (note: nil as String, frequency: 0.0)
       //    return (emptyNote, false) }  // ✅ Prevents out-of-bounds errors
        
        let next = arpeggioNotes[currentIndex]
        currentIndex  = currentIndex + 1
        let isLast = (currentIndex == arpeggioNotes.count) // Defaults to false until the last note

        return (next, isLast)
    }
    
    override var description: String {
        return """
        Basic exercise to step through the keys, clockwise on the circle of fifths,
        and for each key, go thru the root, third and fifth in each octave that 
        is in your range.
        """
    }
}
