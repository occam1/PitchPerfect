import SwiftUI

@main
struct PitchPerfectApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var appManager = AppManager()

init() {
        
        
        // Step 2: Load keys data
        _ = AppDataManager.loadKeysFromJSON()
        
        // Step 3: Load key-notes data
        _ = AppDataManager.loadKeyNotesFromJSON()
        
        print("Initialization complete.")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appManager)
                .onChange(of: scenePhase) { newPhase in
                    switch newPhase {
                    case .active:
                        appManager.resumeProcesses()
                    case .inactive, .background:
                        appManager.pauseProcesses()
                    @unknown default:
                        break
                    }
                }
        }
    }
}
