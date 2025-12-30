//
//  ScheduleEditorView.swift
//  focus
//
//  Created by Evan Yan on 2025-12-29.
//

import SwiftUI
import SwiftData

struct ScheduleEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var scheduleName: String = "Custom"
    @State private var startTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var endTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var selectedDays: Set<Int> = [2, 3, 4, 5, 6] // Mon-Fri
    
    var onScheduleCreated: (() -> Void)? = nil
    
    let daysOfWeek = [
        (1, "Sun"),
        (2, "Mon"),
        (3, "Tue"),
        (4, "Wed"),
        (5, "Thu"),
        (6, "Fri"),
        (7, "Sat")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                PaperTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Schedule Name")
                                .font(.headline)
                                .foregroundColor(PaperTheme.textPrimary)
                            
                            TextField("e.g., Work Hours", text: $scheduleName)
                                .padding()
                                .background(PaperTheme.cardBackground)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(PaperTheme.border, lineWidth: 1)
                                )
                        }
                        
                        // Time Pickers
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Time Range")
                                .font(.headline)
                                .foregroundColor(PaperTheme.textPrimary)
                            
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Start")
                                        .font(.subheadline)
                                        .foregroundColor(PaperTheme.textSecondary)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("End")
                                        .font(.subheadline)
                                        .foregroundColor(PaperTheme.textSecondary)
                                    
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                }
                            }
                            .padding()
                            .background(PaperTheme.cardBackground)
                            .cornerRadius(10)
                        }
                        
                        // Days Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Days")
                                .font(.headline)
                                .foregroundColor(PaperTheme.textPrimary)
                            
                            HStack(spacing: 8) {
                                ForEach(daysOfWeek, id: \.0) { day in
                                    Button(action: {
                                        if selectedDays.contains(day.0) {
                                            selectedDays.remove(day.0)
                                        } else {
                                            selectedDays.insert(day.0)
                                        }
                                    }) {
                                        Text(day.1)
                                            .font(.subheadline.bold())
                                            .foregroundColor(selectedDays.contains(day.0) ? PaperTheme.buttonPrimaryText : PaperTheme.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(selectedDays.contains(day.0) ? PaperTheme.buttonPrimary : PaperTheme.cardBackground)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(PaperTheme.border, lineWidth: selectedDays.contains(day.0) ? 0 : 1)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Quick Presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Presets")
                                .font(.headline)
                                .foregroundColor(PaperTheme.textPrimary)
                            
                            VStack(spacing: 8) {
                                Button(action: {
                                    scheduleName = "Work Hours"
                                    startTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
                                    endTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
                                    selectedDays = [2, 3, 4, 5, 6] // Mon-Fri
                                }) {
                                    HStack {
                                        Text("Work Hours (9 AM - 5 PM, Mon-Fri)")
                                            .font(.subheadline)
                                            .foregroundColor(PaperTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(PaperTheme.textTertiary)
                                    }
                                    .padding()
                                    .background(PaperTheme.cardBackground)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    scheduleName = "Sleep Time"
                                    startTime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
                                    endTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
                                    selectedDays = [1, 2, 3, 4, 5, 6, 7] // Every day
                                }) {
                                    HStack {
                                        Text("Sleep Time (10 PM - 7 AM, Daily)")
                                            .font(.subheadline)
                                            .foregroundColor(PaperTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(PaperTheme.textTertiary)
                                    }
                                    .padding()
                                    .background(PaperTheme.cardBackground)
                                    .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    scheduleName = "Study Time"
                                    startTime = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date()) ?? Date()
                                    endTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
                                    selectedDays = [1, 2, 3, 4, 5, 6, 7] // Every day
                                }) {
                                    HStack {
                                        Text("Study Time (2 PM - 6 PM, Daily)")
                                            .font(.subheadline)
                                            .foregroundColor(PaperTheme.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(PaperTheme.textTertiary)
                                    }
                                    .padding()
                                    .background(PaperTheme.cardBackground)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(PaperTheme.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSchedule()
                    }
                    .foregroundColor(PaperTheme.accentBlue)
                    .disabled(scheduleName.isEmpty || selectedDays.isEmpty)
                }
            }
        }
    }
    
    private func saveSchedule() {
        let schedule = BlockingSchedule(
            name: scheduleName,
            startTime: startTime,
            endTime: endTime,
            daysOfWeek: Array(selectedDays),
            isEnabled: true
        )
        
        ScheduleService.shared.setModelContext(modelContext)
        ScheduleService.shared.addSchedule(schedule)
        
        // Notify parent that schedule was created
        onScheduleCreated?()
        
        dismiss()
    }
}

#Preview {
    ScheduleEditorView()
        .modelContainer(for: [BlockingSchedule.self], inMemory: true)
}

