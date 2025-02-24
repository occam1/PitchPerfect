//
//  ExerciseBase.swift
//  PitchPerfect
//
//  Created by Mark Hall on 2/8/25.
//
import Foundation
class Exercise {
    static var registeredExercises: [String: Exercise] = [:] // ✅ Stores all exercise instances
    
    internal var utility = Utility.shared
    internal var userData: UserData?
    internal var filteredNoteFrequencies: [ String: Float] = [:]
    internal var exerciseNoteFrequencies: [(note: String, frequency: Float)] = [] // ✅ Will be populated dynamically
    
    internal var currentIndex: Int = 0
    internal var incrementer: Int = 1
    var turnDuration: Int?  // Default value

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
     func loadTurnDuration() {
        guard let user = UserData.shared else {
            print("⚠️ UserData.shared is nil! Deferring load.")
            return
        }

        let exerciseId = String(describing: type(of: self)) // Get class name
        turnDuration = user.turnDurations[exerciseId] ?? 10
        print("✅ Loaded turnDuration: \(turnDuration!) for \(exerciseId)")
    }

    func getDuration() -> TimeInterval {
        if turnDuration == nil {
            loadTurnDuration() // ✅ Load only when first accessed
        }
        return TimeInterval(turnDuration!)
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
        
        self.exerciseNoteFrequencies = filteredNoteFrequencies.map { (key, value) in
            (note: key, frequency: value)
        }
    }

    /// ✅ Finds a note at a given interval (in semitones) above the base note
    internal func getInterval(note: String, semitones: Int) -> (String, Float)? {
        guard let index = exerciseNoteFrequencies.firstIndex(where: { $0.0.dropLast(1) == note }) else { return nil }
        let targetIndex = index + semitones
    if targetIndex < exerciseNoteFrequencies.count {
            return exerciseNoteFrequencies[targetIndex]
        }
        return nil
    }
    
    
    /// ✅ Fetch the next note in the sequence
    func nextNote() -> ((note: String, frequency: Float)?,isLastNote: Bool) {
        if currentIndex >= exerciseNoteFrequencies.count {
            reset()  // ✅ Reset when reaching the end
        }
        guard !exerciseNoteFrequencies.isEmpty else {
            
            return (nil, false) }  // ✅ Prevents out-of-bounds errors
        
        let isLast = (currentIndex == exerciseNoteFrequencies.count - 1) // Defaults to false until the last note

        
        let next = exerciseNoteFrequencies[currentIndex]
        currentIndex += incrementer
        return (next, isLast)
    }
   
    /// ✅ Resets the note sequence to reverse direction
    func reset() {
        currentIndex = exerciseNoteFrequencies.count - 1
        incrementer *= -1
    }



    /// ✅ Description of the exercise (subclasses override this)
    var description: String {
        return """
        This base exercise steps through an ordered collection of notes within the user's range,
        ascending through the range and then descending.
        """
    }
    
}
