//
//  UserDataManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI
import Foundation

class UserDataManager {
    private static let directory = getDocumentsDirectory()
    
        // Purge old data
        static func purgeOldData(for user: inout UserData, keepingLast days: Int) {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            user.attempts = user.attempts.filter { $0.date >= cutoffDate }
            saveUserData(user)
        }

    // Load all user data files
    static func loadAllUsers() -> [UserData] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return try fileURLs.compactMap { url in
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(UserData.self, from: data)
            }
        } catch {
            print("Failed to load user data: \(error.localizedDescription)")
            return []
        }
    }

    // Save user data
    static func saveUserData(_ userData: UserData) {
        let fileName = "\(userData.userName).json"
        let fileURL = directory.appendingPathComponent(fileName)

        do {
            let data = try JSONEncoder().encode(userData)
            try data.write(to: fileURL)
            print("Saved data for \(userData.userName)")
        } catch {
            print("Failed to save user data: \(error.localizedDescription)")
        }
    }

    // Helper to get the documents directory
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
