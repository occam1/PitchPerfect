import SwiftUI

@main
struct PitchPerfectApp: App {
    @Environment(\.scenePhase) var scenePhase
    public static let doDebug = false
init() {
    
        
        // Step 2: Load AppDataManager data
        AppDataManager.loadNotesFromJSON()
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
