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
    @State private var showExerciseView: Bool = false
    @State private var selectedUserIndex: Int? = nil

    var body: some View {
        NavigationView {
            Form {
                existingUsersSection()
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
                advancedSettingsSheetView()
            }
            .sheet(isPresented: $showExerciseView) {
                exerciseSheetView()
            }
            .onAppear {
                autoSelectUser() // ✅ Ensure UI updates immediately
            }
            .onDisappear {
                AppManager.shared.resumeProcesses()
            }
        }
    }

    // ✅ Auto-Select Last Used User and Update UI
    private func autoSelectUser() {
        if selectedUser == nil, !users.isEmpty {
            selectedUser = users.first
        }
        selectedUserIndex = users.firstIndex(where: { $0.userName == selectedUser?.userName })
    }

    // ✅ Extracted User Selection Section
    private func existingUsersSection() -> some View {
        Section(header: Text("Existing Users")) {
            ForEach(users.indices, id: \.self) { index in
                HStack {
                    Button(action: { handleUserSelection(index: index) }) {
                        Text(users[index].userName)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    if selectedUser?.userName == users[index].userName {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }

            if users.isEmpty {
                Text("⚠️ No users available. Please create a user first.")
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }

            // ✅ Show buttons only if a user is selected
            if let _ = selectedUserIndex {
                Button("Edit \(selectedUser?.userName ?? "User")'s Advanced Settings") {
                    showAdvancedSettings = true
                }
                .font(.headline)
                .foregroundColor(.blue)

                Button("Edit \(selectedUser?.userName ?? "User")'s Exercises") {
                    showExerciseView = true
                }
                .font(.headline)
                .foregroundColor(.blue)
            }
        }
    }

    // ✅ Extracted Sheets for Better Type-Checking
    private func advancedSettingsSheetView() -> some View {
        Group {
            if let selectedIndex = selectedUserIndex {
                AdvancedSettingsView(
                    advancedSettings: $users[selectedIndex].advancedSettings,
                    showAdvancedSettings: $showAdvancedSettings,
                    user: $users[selectedIndex]
                )
            } else {
                EmptyView()
            }
        }
    }

    private func exerciseSheetView() -> some View {
        Group {
            if let selectedIndex = selectedUserIndex {
                ExerciseView(user: $users[selectedIndex])
            } else {
                EmptyView()
            }
        }
    }

    // ✅ Handle User Selection
    private func handleUserSelection(index: Int) {
        selectedUser = users[index]
        selectedUserIndex = index
    }
}
