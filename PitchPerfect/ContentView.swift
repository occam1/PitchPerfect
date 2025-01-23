import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appManager: AppManager
    @StateObject private var pitchCompareModel = PitchCompareModel()
    
    @State private var showSettings = false
    @State private var users: [UserData] = [] // Replace UserData with your actual user model type
    @State private var selectedUser: UserData? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Pitch Comparison View
                PitchComparisonView(model: pitchCompareModel)
                    .padding()



                Spacer()
            }
            .navigationTitle("PitchPerfect")
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
        }
        .onAppear {
            // Configure the audio session on appear
            Init.configureAudioSession()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
