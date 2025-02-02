//
//  ConfigurationView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI

struct ConfigurationView: View {
    @Binding var users: [UserData]
    @Binding var selectedUser: UserData?
    @Binding var showConfiguration: Bool

    @State private var showAdvancedSettings: Bool = false
    @State private var newUserName: String = ""

    var body: some View {
        NavigationView {
            Form {
                // Section for existing users
                Section(header: Text("Existing Users")) {
                    ForEach(users, id: \.userName) { user in
                        HStack {
                            Button(action: {
                                handleUserSelection(user: user)
                            }) {
                                Text(user.userName)
                                    .foregroundColor(.primary)
                            }

                            Spacer()

                            // Show checkmark for selected user
                            if selectedUser?.userName == user.userName {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }

                    // Advanced Settings button for the selected user
                    if let selectedUser = selectedUser {
                        Button("Edit \(selectedUser.userName)'s Advanced Settings") {
                            showAdvancedSettings = true
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                }

            }
            .navigationTitle("Configuration")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showConfiguration = false
                    }
                }
            }
            .sheet(isPresented: $showAdvancedSettings) {
                if let selectedUserIndex = users.firstIndex(where: { $0.userName == selectedUser?.userName }) {
                    AdvancedSettingsView(
                        advancedSettings: $users[selectedUserIndex].advancedSettings,
                        showAdvancedSettings: $showAdvancedSettings,
                        user: $users[selectedUserIndex]
                    )
                }
            }
        }
    }

    // Handle user selection
    private func handleUserSelection(user: UserData) {
        selectedUser = user
        showAdvancedSettings = true // Force all users to go to Advanced Settings
    }


}
