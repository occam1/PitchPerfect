//
//  AdvancedSettingsView.swift
//  PitchPerfect
//
//  Created by Mark Hall on 1/20/25.
//
import SwiftUI

struct AdvancedSettingsView: View {
    @Binding var advancedSettings: AdvancedSettings
    @Binding var showAdvancedSettings: Bool
    @Binding var user: UserData // Bind the user's data to modify attempts

    @State private var keepLastDays: Int = 30 // Default retention period
    @State private var isRangeExpanded: Bool = true
    @State private var isKeySelectionExpanded: Bool = false
    @State private var isDataManagementExpanded: Bool = false

    let retentionPeriods = [7, 30, 60, 90] // Available options for retention

    var body: some View {
        NavigationView {
            Form {
                // Vocal Range Section
                DisclosureGroup("Vocal Range", isExpanded: $isRangeExpanded) {
                    TextField("Lowest Note", text: $advancedSettings.lowestNote)
                    TextField("Highest Note", text: $advancedSettings.highestNote)
                }

                // Key Selection Section
                           DisclosureGroup("Key Selection", isExpanded: $isKeySelectionExpanded) {
                               KeyPickerView(
                                   keys: AppDataManager.loadKeysFromJSON(),
                                   selectedKey: $advancedSettings.selectedKey
                               )
                           }

           

                // Data Management Section
                DisclosureGroup("Data Management", isExpanded: $isDataManagementExpanded) {
                    Picker("Keep data for", selection: $keepLastDays) {
                        ForEach(retentionPeriods, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Button("Purge Old Data") {
                        UserDataManager.purgeOldData(for: &user, keepingLast: keepLastDays)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Advanced Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showAdvancedSettings = false
                    }
                }
            }
        }
    }
}
