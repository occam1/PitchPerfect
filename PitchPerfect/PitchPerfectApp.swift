import SwiftUI

@main
struct PitchPerfectApp: App {
    @Environment(\.scenePhase) var scenePhase

init() {
        
        
        // Step 2: Load keys data
        _ = AppDataManager.loadKeysFromJSON()
        
        // Step 3: Load key-notes data
        AppDataManager.loadKeyNotesFromJSON()
        AppDataManager.loadEnharmonicsFromJSON()
        AppDataManager.loadNoteFrequenciesFromJSON()
        
        print("Initialization complete.")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppManager.shared) // Inject the singleton instance
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                AppManager.shared.resumeProcesses()
            case .inactive, .background:
                AppManager.shared.pauseProcesses()
            @unknown default:
                break
            }
        }
    }
}
