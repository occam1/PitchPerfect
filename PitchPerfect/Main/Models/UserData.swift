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

    private init(userName: String, advancedSettings: AdvancedSettings) {
        self.userName = userName
        self.advancedSettings = advancedSettings
    }
    // ✅ Coding Keys for manual encoding/decoding
    enum CodingKeys: String, CodingKey {
        case userName
        case advancedSettings
    }

    // ✅ Custom Decoder
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.advancedSettings = try container.decode(AdvancedSettings.self, forKey: .advancedSettings)
    }

    // ✅ Custom Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encode(advancedSettings, forKey: .advancedSettings)
    }

    // ✅ Call this when the user selects an account
    static func setActiveUser(user: UserData) {
        shared = user
        user.save() // Persist user selection
    }

    // ✅ Load user by username (if it exists)
    static func loadUser(userName: String) -> UserData? {
        return UserDataManager.loadUser(userName: userName)
    }

    // ✅ Function to set a new user (Singleton pattern)
    static func createNewUser(userName: String) {
        let newUser = UserData(
            userName: userName,
            advancedSettings: AdvancedSettings(
                lowestNote: "",
                midBridge: "",
                highestNote: "",
                selectedKey: "C"
            )
        )
        shared = newUser
        newUser.save() // ✅ Save the new user
        print("📂 Saving user at: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)")
        
    }

    // ✅ Save user and store last used username
    func save() {
        UserDataManager.saveUserData(self)
        UserDefaults.standard.set(self.userName, forKey: "lastUser")
    }
}
