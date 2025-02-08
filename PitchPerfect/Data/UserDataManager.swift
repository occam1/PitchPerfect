//
//  UserDataManager.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//


import Foundation

class UserDataManager {
    static private(set) var users: [UserData] = []  // Collection of all users
    static private(set) var currentUser: UserData?
    

    
    static func loadAllUsers() -> [UserData] {
        let directory = getDocumentsDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            let userFiles = files.filter { $0.pathExtension == "json" }
            
            print("📂 Found user files: \(userFiles)")
            
            let users = userFiles.compactMap { fileURL -> UserData? in
                do {
                    let data = try Data(contentsOf: fileURL)
                    let user = try JSONDecoder().decode(UserData.self, from: data)
                    print("✅ Loaded user: \(user.userName)")
                    return user
                } catch {
                    print("❌ Failed to load user at \(fileURL): \(error)")
                    return nil
                }
            }
            
            return users
        } catch {
            print("❌ Failed to list user files: \(error)")
            return []
        }
    }

    /// Loads a user by name and sets them as the active user
    static func loadUser(userName: String) {
        guard let user = users.first(where: { $0.userName == userName }) else {
            print("❌ User '\(userName)' not found")
            return
        }

        currentUser = user  // ✅ Set as active user
        
        user.save()  // ✅ Persist the selection
        UserDefaults.standard.set(userName, forKey: "lastUser")  // ✅ Save last chosen user

        print("✅ Loaded user: \(userName)")
    }
    
    
    static func saveUserData(_ user: UserData) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(user)
            let fileURL = getDocumentsDirectory().appendingPathComponent("\(user.userName).json")
            
            try data.write(to: fileURL)
            print("✅ User data saved successfully at \(fileURL)")
        } catch {
            print("❌ Failed to save user data: \(error)")
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
