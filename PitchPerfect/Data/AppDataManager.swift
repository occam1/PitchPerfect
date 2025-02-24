//
//  AppDataManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI
import Foundation

class AppDataManager {
    // Static properties to hold data
    public static let shared = AppDataManager()
    public static var notes: [String] = []
    public static var circleOfFifths: [String] = []
    public static var enharmonics: [String: String] = [:]
    public static var keyNotes: [String: [String]] = [:]
    public static var noteFrequencies: [String: Float] = [:]
    public static var exercises: [String:Bool] = [:]
    
    // Static initializer to load data
    //static func initialize() {
    //self.keys = loadKeysFromJSON()
    // self.loadKeyNotesFromJSON()
    //self.loadEnharmonicsFromJSON()
    //self.loadNoteFrequenciesFromJSON()
    //}
    
    
    // Static function to access keys with their notes
    static func getKeyNotes() -> [String: [String]] {
        return keyNotes
    }
    
    // Private static function to load just the keys
    public static func loadNotesFromJSON() {
        // Get the URL for the JSON file in the bundle
        guard let fileURL = Bundle.main.url(forResource: "notes", withExtension: "json") else {
            print("notes.json not found in bundle.")
            return
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: fileURL)
            
            // Decode the JSON data into an array of strings
            let notesDecoded = try JSONDecoder().decode([String].self, from: data)
            self.notes = notesDecoded
        } catch {
            print("Error loading or decoding notes.json: \(error)")
            return
        }
    }
    // Private static function to load just the keys
    public static func loadCircleOfFifthsFromJSON() {
        // Get the URL for the JSON file in the bundle
        guard let fileURL = Bundle.main.url(forResource: "circleOfFifths", withExtension: "json") else {
            print("circleOfFifths.json not found in bundle.")
            return
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: fileURL)
            
            // Decode the JSON data into an array of strings
           let circleOfFifthsDecoded = try JSONDecoder().decode([String].self, from: data)
            self.circleOfFifths = circleOfFifthsDecoded
        } catch {
            print("Error loading or decoding circleOfFifths.json: \(error)")
            return
        }
    }
    
    
    static func loadKeyNotesFromJSON()   {
        guard let url = Bundle.main.url(forResource: "keyNotes", withExtension: "json") else {
            print("KeyNotes.json not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            // Decode directly as a dictionary
            let decodedKeyNotes = try JSONDecoder().decode([String: [String]].self, from: data)
            keyNotes = decodedKeyNotes
            if PitchPerfectApp.doDebug {
                print("Loaded \(keyNotes.count) keys with notes.")
            }
        } catch {
            print("Error loading keyNotes.json: \(error)")
            return
        }
    }
    
    static func loadEnharmonicsFromJSON() {
        if PitchPerfectApp.doDebug {
            print("starting to load Enharmonics")
        }
        guard let fileURL = Bundle.main.url(forResource: "enharmonics", withExtension: "json") else {
            print("enharmonices.json not found in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decodedEnharmonics = try JSONDecoder().decode([String:String].self, from: data)
            enharmonics=decodedEnharmonics
           // if PitchPerfectApp.doDebug {
                print("Loaded \(enharmonics.count) note enharmonics.")
            print("enharmonics: \(self.enharmonics)")
                
           // }
        } catch {
            print("Error loading enharmonics.json: \(error)")
        }
    }
    
    
    static func loadNoteFrequenciesFromJSON() {
        if PitchPerfectApp.doDebug {
            print("starting to load Note Frequencies")
        }
        guard let fileURL = Bundle.main.url(forResource: "noteFrequencies", withExtension: "json") else {
            print("noteFrequencies.json not found in bundle.")
            return
        }
        
        do {
            
            let data = try Data(contentsOf: fileURL)
            noteFrequencies = try JSONDecoder().decode([String: Float].self, from: data)
            if PitchPerfectApp.doDebug {
                print("Loaded \(noteFrequencies.count) note frequencies. ,\(noteFrequencies)")
            }
        } catch {
            print("Error loading noteFrequencies.json: \(error)")
        }
    }
    
    
    
    static func loadExercisesFromJSON() {
           // if PitchPerfectApp.doDebug {
                print("starting to load Exercises")
            //}
            guard let fileURL = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
                print("exercises.json not found in bundle.")
                return
            }
            
            do {
                
                let data = try Data(contentsOf: fileURL)
                exercises = try JSONDecoder().decode([String: Bool].self, from: data)
                
               // if PitchPerfectApp.doDebug {
                    print("Loaded \(exercises.count) exercises. ,\(exercises)")
               // }
            } catch {
                print("Error loading exercises.json: \(error)")
            }
        }
        
}

// Private static function to load keys with their corresponding notes
struct KeyNotesData: Decodable {
    let keyNotes: [String: [String]]
}

struct NoteFrequency: Decodable {
    let name: String
    let frequency: Float
}
struct Enharmonics: Decodable {
    let noteName: String
    let enharmonicName: String
}

