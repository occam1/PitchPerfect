//
//  ExerciseMajorArpeggioChromatic.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/8/25.
//
class ExerciseMajorArpeggioChromatic: Exercise {
    private var arpeggioNotes: [(String, Float)] = []  // Filtered notes for the exercise
    override var exerciseName: String {
        return "Major Arpeggio Chromatic"
    }
    private var noteIndex: Int = 0

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

    func generateArpeggioNotes()  {
        arpeggioNotes.removeAll() // Start fresh

        for key in AppDataManager.keyNotes.keys {
            guard let keyNotes = AppDataManager.keyNotes[key], keyNotes.count >= 5 else {
                print("Invalid key data for \(key)")
                continue
            }
            // Convert flats to sharps if needed before searching in `notes`
            let root = AppDataManager.enharmonics[keyNotes[0]] ?? keyNotes[0]
            let third = AppDataManager.enharmonics[keyNotes[2]] ?? keyNotes[2]
            let fifth = AppDataManager.enharmonics[keyNotes[4]] ?? keyNotes[4]

            // Find first and last occurrence of root and fifth
            // Find first and last occurrence of root and fifth
            guard let firstIndex = exerciseNoteFrequencies.firstIndex(where: { $0.0.dropLast(1) == root }),
                  let lastIndex = exerciseNoteFrequencies.lastIndex(where: { $0.0.dropLast(1) == fifth }),
                      lastIndex > firstIndex else {
                    print("Invalid indices for key \(key)")
                    continue
                }
             
          
            // Process notes from firstIndex to lastIndex
            for index in stride(from: firstIndex, through: lastIndex, by: 12) {
                if index < exerciseNoteFrequencies.count { arpeggioNotes.append(exerciseNoteFrequencies[index]) } // Root

                let thirdIndex = index + 4
               
                if thirdIndex <= lastIndex, thirdIndex < exerciseNoteFrequencies.count, exerciseNoteFrequencies[thirdIndex].0.dropLast(1) == third {
                    arpeggioNotes.append(exerciseNoteFrequencies[thirdIndex]) // Third
                }

                let fifthIndex = index + 7

                if fifthIndex <= lastIndex, fifthIndex < exerciseNoteFrequencies.count, exerciseNoteFrequencies[fifthIndex].0.dropLast(1) == fifth {
                    arpeggioNotes.append(exerciseNoteFrequencies[fifthIndex]) // Fifth
                }
            }
        }
    }

    override func nextNote() -> ((note: String, frequency: Float)?, isLast:Bool)  {
        currentIndex  = currentIndex + 1
        if currentIndex >= arpeggioNotes.count {
            currentIndex = 0
        }
        if arpeggioNotes.isEmpty { return (nil, false) }  // No notes to return
        
       //guard !exerciseNoteFrequencies.isEmpty else {
       //    var emptyNote : (String,Float) = (note: nil as String, frequency: 0.0)
       //    return (emptyNote, false) }  // ✅ Prevents out-of-bounds errors
        
        let next = arpeggioNotes[currentIndex]
        let isLast = (currentIndex == arpeggioNotes.count - 1) // Defaults to false until the last note

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
