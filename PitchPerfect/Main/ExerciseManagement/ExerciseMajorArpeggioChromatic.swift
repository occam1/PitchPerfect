//
//  ExerciseMajorArpeggioChromatic.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/8/25.
//
class ExerciseMajorArpeggioChromatic: Exercise {
    override var exerciseName: String {
        return "MajorArpeggioChromatic"
    }



    override init() {
        super.init()
        Exercise.registerExercise(name: "ExerciseMajorArpeggioChromatic", instance: self)
        generateArpeggioSequence()
    }

    /// ✅ Generates a chromatic-based arpeggio sequence
    private func generateArpeggioSequence() {
        var sequence: [(String, Float)] = []
        var ascending = true

        while true {
            for (note, frequency) in (ascending ? notes : notes.reversed()) {
                if let majorThird = getInterval(note: note, semitones: 4),
                   let perfectFifth = getInterval(note: note, semitones: 7) {
                    guard let user = UserData.shared else {
                        fatalError("❌ UserData.shared is not initialized. A user must be set before creating an Exercise.")
                    }
                    
                    if perfectFifth.1 > user.highestFrequency {
                        ascending = false  // ✅ Reverse direction if the 5th is out of range
                    }

                    sequence.append((note, frequency))  // Root note
                    sequence.append(majorThird)         // Major 3rd
                    sequence.append(perfectFifth)       // Perfect 5th
                }
            }
            
            if !ascending { break }  // ✅ Stop when descending completes
        }

        notes = sequence  // ✅ Updates `notes` with the arpeggio pattern
    }


    
    override var description: String {
        return """
        Plays a chromatic note, followed by its major 3rd and major 5th.
        Once the 5th is out of range, the sequence reverses in chromatic steps 
        while still playing the 3rd and 5th above each new base note.
        """
    }
    
}
