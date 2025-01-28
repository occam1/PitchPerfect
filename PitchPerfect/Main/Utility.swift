//
//  Utility.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/27/25.
//

class Utility {
    public static let shared = Utility()
    
    
    func convertToNoteOctave(from octaveNote: String) -> String {
        // Split the string into the octave and note components
        let octave = String(octaveNote.prefix(1))    // First character is the octave
        let note = String(octaveNote.dropFirst(1))   // Remaining part is the note
        return "\(note)\(octave)"                   // Combine note and octave in desired format
    }
}
