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
    public static var keys: [String] = []
    public static var enharmonics: [String: [String]] = [:]
    public static var keyNotes: [String: [String]] = [:]
    public static var noteFrequencies: [String: [Float]] = [:]

    // Static initializer to load data
    static func initialize() {
        self.keys = loadKeysFromJSON()
        self.keyNotes = loadKeyNotesFromJSON()
    }

    // Static function to access just the keys
    static func getKeys() -> [String] {
        return keys
    }

    // Static function to access keys with their notes
    static func getKeyNotes() -> [String: [String]] {
        return keyNotes
    }

    // Private static function to load just the keys
    public static func loadKeysFromJSON() -> [String] {
        guard let fileURL = Bundle.main.url(forResource: "keys", withExtension: "json") else {
            print("keys.json not found in bundle.")
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let keysData = try JSONDecoder().decode(KeysData.self, from: data)
            return keysData.keys.sorted() // Sort keys alphabetically
        } catch {
            print("Error loading keys.json: \(error)")
            return []
        }
    }

    // Private static function to load keys with their corresponding notes
    public static func loadKeyNotesFromJSON() -> [String: [String]] {
        guard let fileURL = Bundle.main.url(forResource: "keyNotes", withExtension: "json") else {
            print("keyNotes.json not found in bundle.")
            return [:]
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let keyNotesData = try JSONDecoder().decode(KeyNotesData.self, from: data)
            return keyNotesData.keyNotes
        } catch {
            print("Error loading keyNotes.json: \(error)")
            return [:]
        }
    }


    static func loadNoteFrequenciesFromJSON() {
        guard let fileURL = Bundle.main.url(forResource: "noteFrequencies", withExtension: "json") else {
            print("noteFrequencies.json not found in bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let noteFrequencies = try JSONDecoder().decode([NoteFrequency].self, from: data)
           // noteFrequencies = decodedData
            print("Loaded \(noteFrequencies.count) note frequencies.")
        } catch {
            print("Error loading noteFrequencies.json: \(error)")
        }
    }
    static func loadEnharmonicsFromJSON() {
        guard let fileURL = Bundle.main.url(forResource: "enharmonics", withExtension: "json") else {
            print("enharmonices.json not found in bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let enharmonics = try JSONDecoder().decode([Enharmonics].self, from: data)
            //enharmonics = decodedData
            print("Loaded \(enharmonics.count) note enharmonics.")
        } catch {
            print("Error loading enharmonics.json: \(error)")
        }
    }
}

// Struct for keys only
struct KeysData: Decodable {
    let keys: [String]
}

// Struct for keys and their notes
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
