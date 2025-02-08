//
//  ExerciseChromaticStep.swift
//  PitchPerfect
//

//
class ExerciseChromaticStep: Exercise {
    override var exerciseName : String {
     return "Chromatic Step"
 }
 
    override init() {
        super.init()
        sortNotesByFrequency()  // ✅ Sort immediately upon initialization
    }
    //notes and fileterNoteFrequencies are defined in the base class
    func nextNote(currentNote: String?) -> (String,Float)? {
        guard currentIndex < notes.count else { return nil }
        let next = notes[currentIndex]
        currentIndex += 1
        return next
    }

    override func reset() {
        currentIndex = 0
    }
    
   override func nextNote() -> (note: String, frequency: Float)?{
        if currentIndex >= notes.count {
            reset()  // ✅ Reset if at the end
        }
        guard !notes.isEmpty else { return nil }  // ✅ Prevent out-of-bounds errors
        
        let next = notes[currentIndex]
        currentIndex += incrementer
        return next
    }
    
    func sortNotesByFrequency() {
        notes.sort { (a: (String, Float), b: (String, Float)) in
            a.1 < b.1  // ✅ Sort by frequency (Float), which is the second element
        }
    }
    override var description: String {
        return """
        This chromatic exercise steps thru an ordered collection of notes within the users range        
        ascending thru the range then starting again from the lowest note in the users range steps 
        through them again until or unless another exercise is selected
        """
    }
}
