//
//  UserDataModel.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI
import Foundation

class UserData: Codable, ObservableObject {
    static var shared: UserData?

    @Published var userName: String
    @Published var advancedSettings: AdvancedSettings
    @Published var selectedExercises: [String] // ✅ Tracks user's selected exercises
    @Published var turnDurations: [String: Int] // ✅ Stores turnDuration per exercise

    var lowestFrequency: Float = 0.0
    var highestFrequency: Float = 0.0

    private init(userName: String, advancedSettings: AdvancedSettings, selectedExercises: [String]) {
        self.userName = userName
        self.advancedSettings = advancedSettings
        self.selectedExercises = ["ExerciseArpeggiosByKey"] // ✅ Default exercise on creation
        self.turnDurations = [:] // ✅ Empty dictionary, will be populated dynamically
        populateFrequencies()  // ✅ Automatically set frequencies when UserData is initialized
    }

    // ✅ Coding Keys for manual encoding/decoding
    enum CodingKeys: String, CodingKey {
        case userName
        case advancedSettings
        case lowestFrequency
        case highestFrequency
        case selectedExercises // ✅ Add selectedExercises to persisted data
        case turnDurations
    }

    // ✅ Custom Decoder
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.advancedSettings = try container.decode(AdvancedSettings.self, forKey: .advancedSettings)
        self.lowestFrequency = try container.decodeIfPresent(Float.self, forKey: .lowestFrequency) ?? 0.0
        self.highestFrequency = try container.decodeIfPresent(Float.self, forKey: .highestFrequency) ?? 0.0
        self.selectedExercises = try container.decodeIfPresent([String].self, forKey: .selectedExercises) ?? ["ExerciseArpeggiosByKey"]
        self.turnDurations = try container.decodeIfPresent([String: Int].self, forKey: .turnDurations) ?? [:]

        print("decoding selectedExercises: \(self.selectedExercises)")
        
    }

    // ✅ Custom Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(advancedSettings, forKey: .advancedSettings)
        try container.encode(lowestFrequency, forKey: .lowestFrequency)
        try container.encode(highestFrequency, forKey: .highestFrequency)
        print("encoding selectedExercises: \(selectedExercises)")
        try container.encode(selectedExercises, forKey: .selectedExercises) // ✅ Persist selected exercises        
        try container.encode(turnDurations, forKey: .turnDurations)
    }

    /// ✅ Automatically sets lowest & highest frequencies when user data is loaded
    func populateFrequencies() {
        lowestFrequency = AppDataManager.noteFrequencies[advancedSettings.lowestNote] ?? 0.0
        highestFrequency = AppDataManager.noteFrequencies[advancedSettings.highestNote] ?? 0.0
    }

    // ✅ Call this when the user selects an account
    static func setActiveUser(user: UserData) {
        shared = user
        shared?.populateFrequencies()
        user.save()
    }

    // ✅ Load user by username (if it exists)
    static func loadUser(userName: String) {
        UserDataManager.loadUser(userName: userName)
        return
    }

    // ✅ Function to set a new user (Singleton pattern)
    static func createNewUser(userName: String) {
        let newUser = UserData(
            userName: userName,
            advancedSettings: AdvancedSettings(
                lowestNote: "",
                midBridge: "",
                highestNote: "",
                selectedKey: "C",
                audioFeedbackEnabled: true
            ),
            selectedExercises: ["ExerciseArpeggiosByKey"] // ✅ Default to only Chromatic Step
        )
        shared = newUser
        shared?.populateFrequencies()
        newUser.save()
    }

    // ✅ Save user and store last used username
    func save() {
        UserDataManager.saveUserData(self)
        UserDefaults.standard.set(self.userName, forKey: "lastUser")
    }
    
    // ✅ Toggle an exercise selection
    func toggleExerciseSelection(exerciseName: String) {
        if selectedExercises.contains(exerciseName) {
            selectedExercises.removeAll { $0 == exerciseName }
        } else {
            selectedExercises.append(exerciseName)
        }
        save() // ✅ Persist changes immediately
    }
}
