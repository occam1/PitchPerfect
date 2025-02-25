//
//  ExerciseChromaticStep.swift
//  PitchPerfect
//

//
class ExerciseChromaticStep: Exercise {
    static let shared = ExerciseChromaticStep()
    override var exerciseName : String {
     return "Chromatic Step"
 }
 
    override init() {
        super.init()
        print("✅ ExerciseChromaticStep initialized") // Debugging print
        //Exercise.registerExercise(name: "ExerciseChromaticStep", instance: self)
     
    }


    override func reset() {
        print("ECS reset")
        currentIndex = 0
        incrementer = 1
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

    override func nextNote() -> ((note: String, frequency: Float)?, isLast : Bool)  {
        if (currentIndex >= exerciseNoteFrequencies.count - 1) {
            currentIndex = exerciseNoteFrequencies.count - 1
            incrementer = -1  // ✅ Reset if at the top end
        }
        if (currentIndex == 0) {
            incrementer = 1  // ✅ Reset if at the bottom end
        }
        guard !exerciseNoteFrequencies.isEmpty else { return (nil, false) }  // ✅ Prevent out-of-bounds errors
        let isLast = (currentIndex == 1 && incrementer == -1) // Defaults to false until the last note
        print("ECS isLast: \(isLast)")
        let next = exerciseNoteFrequencies[currentIndex]
        currentIndex += incrementer
        
        return (next, isLast)

    }
    public override func getDescription() -> String {
        return description
    }
    

    override var description: String {
        return """
        This chromatic exercise steps thru an ordered collection of notes within the singer's range        
        ascending thru notes then descending back to the lowest note in the singer's range
        """
    }
}
