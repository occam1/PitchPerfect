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
                    TextField("Mid Bridge", text: $advancedSettings.midBridge)
                    TextField("Highest Note", text: $advancedSettings.highestNote)
                }

                // Key Selection Section
                           DisclosureGroup("Key Selection", isExpanded: $isKeySelectionExpanded) {
                               KeyPickerView(
                                    keys: AppDataManager.notes,
                                   selectedKey: $advancedSettings.selectedKey
                               )
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
