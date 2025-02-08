//
//  ExerciseBase.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/8/25.
//
class Exercise {
    internal var utility = Utility.shared
    internal var userData : UserData
    internal var filteredNoteFrequencies: [String: Float] = [:]
    internal var currentIndex: Int = 0
    var exerciseName : String {
        return "BaseExercise"
    }
    var isGlidingTone: Bool {
        return false  // Default implementation
    }
    var glidingNote: String? {
        return nil
    }

    internal var notes: [(String, Float)] = []
    internal var incrementer : Int = 1


    init() {
        guard let user = UserData.shared else {
            fatalError("❌ UserData.shared is not initialized. A user must be set before creating an Exercise.")
        }
        
        self.userData = user
        print("✅ ExerciseBase initialized with user: \(user.userName)")
        // Get user's vocal range
        let minFreq = self.userData.lowestFrequency
        let maxFreq = self.userData.highestFrequency

        self.filteredNoteFrequencies = AppDataManager.noteFrequencies.filter { (note, frequency) in
            frequency >= minFreq && frequency <= maxFreq
        }
        self.notes  = Array(filteredNoteFrequencies)
    }
    func start() {
        print("default implementation of start in ExerciseBase...")
    }
    
    func nextNote() -> (note: String, frequency: Float)?{
        if currentIndex >= notes.count {
            reset()  // ✅ Reset if at the end
        }
        guard !notes.isEmpty else { return nil }  // ✅ Prevent out-of-bounds errors
        
        let next = notes[currentIndex]
        currentIndex += incrementer
        return next
    }

    
    func reset() {
        currentIndex = notes.count - 1
        incrementer *= -1
    }
    /// ✅ Finds a note at a given interval (in semitones) above the base note
    internal func getInterval(note: String, semitones: Int) -> (String, Float)? {
        guard let index = notes.firstIndex(where: { $0.0 == note }) else { return nil }
        let targetIndex = index + semitones

        if targetIndex < notes.count {
            return notes[targetIndex]
        }
        return nil
    }

    var description: String {
        return """
        This base exercise steps thru an ordered collection of notes within the users range
        ascending thru the range then descending
        """
    
    }
}
