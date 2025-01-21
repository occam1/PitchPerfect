import SwiftUI

@main
struct PitchPerfectApp: App {
    init() {
          // Step 1: Configure the audio session
          Init.configureAudioSession()
          
          // Step 2: Load keys data
          _ = AppDataManager.loadKeysFromJSON()
          
          // Step 3: Load key-notes data
          _ = AppDataManager.loadKeyNotesFromJSON()
          
          print("Initialization complete.")
      }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
