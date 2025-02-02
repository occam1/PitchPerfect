import SwiftUI
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appManager: AppManager
    @ObservedObject private var pitchCompareModel = PitchCompareModel.shared

    @State private var showSettings = false
    @State private var showUserSelection = false
    @State private var users: [UserData] = []
    @State private var selectedUser: UserData?

    var body: some View {
        NavigationView {
            VStack {
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
            .navigationTitle("Pitch Practice - \(UserData.shared?.userName ?? "No User")")
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
                // ✅ Forces user selection before using the app
                UserSelectionView(users: $users, selectedUser: $selectedUser, showUserSelection: $showUserSelection)
            }
        }
        .onAppear {
            Init.configureAudioSession()
            loadUsers()
            //appManager.checkUserStatus()
                
        }
    }

    // MARK: - Button Actions

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
        users = UserDataManager.loadAllUsers() // ✅ Load all users at start

        if let lastUserName = UserDefaults.standard.string(forKey: "lastUser"),
           let lastUser = users.first(where: { $0.userName == lastUserName }) {
            UserData.setActiveUser(user: lastUser) // ✅ Set last active user
            selectedUser = lastUser
            showUserSelection = true
        } else {
            showUserSelection = true // ✅ Force user selection if no last user
        }
    }
}
