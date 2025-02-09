//
//  ExerciseBase.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/8/25.
//
class Exercise {
    static var registeredExercises: [String: Exercise] = [:] // ✅ Stores all exercise instances
    
    internal var utility = Utility.shared
    internal var userData: UserData?
    internal var filteredNoteFrequencies: [String: Float] = [:]
    internal var notes: [(String, Float)] = [] // ✅ Will be populated dynamically
    internal var currentIndex: Int = 0
    internal var incrementer: Int = 1

    /// ✅ Name of the exercise (must be overridden)
    var exerciseName: String {
        fatalError("Subclasses must override `exerciseName`.")
    }

    /// ✅ Determines if the exercise involves gliding tones
    var isGlidingTone: Bool {
        return false  // Default implementation
    }

    /// ✅ If gliding, which note is being used
    var glidingNote: String? {
        return nil
    }

    /// ✅ Registers the exercise instance dynamically
    static func registerExercise(name: String, instance: Exercise) {
        registeredExercises[name] = instance
    }

    /// ✅ Initializes and automatically registers the exercise
    init() {
        let exerciseClass = String(describing: type(of: self)) // ✅ Always returns a valid string
        Exercise.registerExercise(name: exerciseClass, instance: self)
        
    }

    /// ✅ Starts the exercise (overridable)
    func startExercise() {
        print("🚀 Starting base exercise...")
        getUsersRange() // ✅ Load user's range on start
    }

    /// ✅ Get user's vocal range and filter note frequencies
    func getUsersRange() {
        guard let user = UserData.shared else {
            fatalError("❌ UserData.shared is not initialized. A user must be set before creating an Exercise.")
        }

        self.userData = user
        print("✅ ExerciseBase initialized with user: \(user.userName)")

        // ✅ Filter notes within user's vocal range
        let minFreq = user.lowestFrequency
        let maxFreq = user.highestFrequency

        self.filteredNoteFrequencies = AppDataManager.noteFrequencies.filter { (_, frequency) in
            frequency >= minFreq && frequency <= maxFreq
        }
        
        self.notes = Array(filteredNoteFrequencies)
    }

    /// ✅ Fetch the next note in the sequence
    func nextNote() -> (note: String, frequency: Float)? {
        if currentIndex >= notes.count {
            reset()  // ✅ Reset when reaching the end
        }
        guard !notes.isEmpty else { return nil }  // ✅ Prevents out-of-bounds errors
        
        let next = notes[currentIndex]
        currentIndex += incrementer
        return next
    }
   
    /// ✅ Resets the note sequence to reverse direction
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

    /// ✅ Description of the exercise (subclasses override this)
    var description: String {
        return """
        This base exercise steps through an ordered collection of notes within the user's range,
        ascending through the range and then descending.
        """
    }
    
}
