import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appManager: AppManager
    @ObservedObject private var pitchCompareModel = PitchCompareModel.shared
    @ObservedObject var exerciseManager = ExerciseManager.shared

    @State private var showSettings = false
    @State private var showUserSelection = false
    @State private var users: [UserData] = []
    @State private var selectedUser: UserData?
    @State private var exerciseName: String = "No Exercise Selected"

    var body: some View {
        NavigationView {
            ZStack {
                pitchColor()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    // Title + Exercise Name
                    VStack {
                        Text("Pitch Practice")
                            .font(.largeTitle)
                            .bold()
                        
                        Text(exerciseManager.currentExerciseName) // ✅ Exercise name below title
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Pitch Comparison View
                    PitchComparisonView()
                        .padding()
                    
                    Spacer()
                    
                    // Automatic/Manual Toggle Button
                    Button(action: toggleMode) {
                        Text(pitchCompareModel.isAutomatic ? "Switch to Manual" : "Switch to Automatic")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(pitchCompareModel.isAutomatic ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    // Pause/Next/Resume Button
                    Button(action: handlePauseNextResume) {
                        Text(buttonLabelText())
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline) // ✅ Ensures space for content
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Settings") {
                            showSettings = true
                            appManager.pauseProcesses()
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    ConfigurationView(
                        users: $users,
                        selectedUser: $selectedUser,
                        showConfiguration: $showSettings
                    )
                }
                .sheet(isPresented: $showUserSelection) {
                    UserSelectionView(users: $users, selectedUser: $selectedUser, showUserSelection: $showUserSelection)
                }
            }
            .onAppear {
                Init.configureAudioSession()
                loadUsers()
                
            }
        }
    }
    // MARK: - Helper Functions

    private func pitchColor() -> Color {
        let maxError: Float = 50.0
        let normalizedError = max(-maxError, min(maxError, pitchCompareModel.pitchErrorCents)) / maxError

        let red = max(0.0, -normalizedError)
        let blue = max(0.0, normalizedError)
        let closeness = 1.0 - abs(normalizedError)

        // Slight yellow-green tint near the center
        let greenBoost = 0.4 * closeness

        let redComponent = whiteBlend(Double(red), Double(closeness)) + Double(greenBoost) * 0.3
        let greenComponent = whiteBlend(0.0, Double(closeness)) + Double(greenBoost)
        let blueComponent = whiteBlend(Double(blue), Double(closeness)) + Double(greenBoost) * 0.2

        return Color(red: redComponent, green: greenComponent, blue: blueComponent)
    }

    // Helper for blending with white
    private func whiteBlend(_ component: Double, _ closeness: Double) -> Double {
        return Double(component * (1 - closeness) + closeness)
    }
    
    private func toggleMode() {
        pitchCompareModel.isAutomatic.toggle()
        pitchCompareModel.isPaused = false
    }

    private func handlePauseNextResume() {
        if pitchCompareModel.isAutomatic {
            pitchCompareModel.isPaused.toggle()
            print(pitchCompareModel.isPaused ? "Playback paused" : "Playback resumed")
        } else {
            print("Next pitch")
            pitchCompareModel.isPaused = false
        }
    }

    private func buttonLabelText() -> String {
        if pitchCompareModel.isAutomatic {
            return pitchCompareModel.isPaused ? "Resume" : "Pause"
        } else {
            return "Next"
        }
    }

    private func loadUsers() {
        users = UserDataManager.loadAllUsers()

        if let lastUserName = UserDefaults.standard.string(forKey: "lastUser"),
           let lastUser = users.first(where: { $0.userName == lastUserName }) {
            UserData.setActiveUser(user: lastUser)
            selectedUser = lastUser
            showUserSelection = true
        } else {
            showUserSelection = true
        }
    }
}
