//
//  MedicationDetailView.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
import SwiftUI
import Foundation
import SwiftUI

struct MedicationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: MedicationDetailViewModel
    @Binding var medications: [Medication]
    @State private var showingTimePicker = false
    @State private var showingStartDatePicker = false
    @State private var showingEndDatePicker = false
    
    init(medication: Medication, medications: Binding<[Medication]>) {
        _viewModel = StateObject(wrappedValue: MedicationDetailViewModel(medication: medication))
        _medications = medications
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    if viewModel.isEditing {
                        // Edit Mode
                        editModeContent
                    } else {
                        // View Mode
                        viewModeContent
                    }
                }
                .padding(.vertical, AppTheme.Spacing.lg)
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Medication" : viewModel.medication.name)
        .navigationBarItems(
            trailing: HStack {
                if !viewModel.isEditing {
                    Menu {
                        Button(role: .destructive, action: {
                            viewModel.deleteMedication(from: medications) { updatedMedications in
                                DispatchQueue.main.async {
                                    medications = updatedMedications
                                    presentationMode.wrappedValue.dismiss() // Dismiss the view after deletion
                                }
                            }
                        }) {
                            Label("Delete Medication", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(AppTheme.Colors.primary)
                    }
                }
                
                Button(viewModel.isEditing ? "Save" : "Edit") {
                    if viewModel.isEditing {
                        viewModel.saveMedicationChanges(in: medications) { updatedMedications in
                            DispatchQueue.main.async {
                                medications = updatedMedications
                                viewModel.isEditing.toggle()
                            }
                        }
                    } else {
                        viewModel.isEditing.toggle()
                    }
                }
            }
        )
        .sheet(isPresented: $showingTimePicker) {
            NavigationView {
                DatePicker("Time", selection: $viewModel.editedTimeOfDay, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .navigationBarItems(trailing: Button("Done") { showingTimePicker = false })
                    .navigationBarTitleDisplayMode(.inline)
                    .padding()
            }
        }
    }
    
    private var viewModeContent: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Medication Details Section
            DetailSection(title: "Medication Details", icon: "pills.fill") {
                DetailRow(title: "Name", value: viewModel.medication.name)
                DetailRow(title: "Dosage", value: viewModel.medication.dosage)
                DetailRow(title: "Status", value: viewModel.medication.isActive ? "Active" : "Inactive") {
                    Toggle("", isOn: Binding(
                        get: { viewModel.medication.isActive },
                        set: { newValue in
                            var updatedMedication = viewModel.medication
                            updatedMedication.isActive = newValue
                            StorageManager.shared.updateMedication(updatedMedication, in: medications) { updatedMedications in
                                DispatchQueue.main.async {
                                    medications = updatedMedications
                                    if newValue {
                                        NotificationManager.shared.scheduleNotifications(for: updatedMedication)
                                    } else {
                                        NotificationManager.shared.removeNotifications(for: updatedMedication)
                                    }
                                    viewModel.medication = updatedMedication
                                }
                            }
                        }
                    ))
                }
            }
            
            // Schedule Section
            DetailSection(title: "Schedule", icon: "clock.fill") {
                DetailRow(title: "Time", value: DateUtilities.formatTime(viewModel.medication.timeOfDay))
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Days")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(1...7, id: \.self) { day in
                            WeekdayButton(
                                day: day,
                                isSelected: viewModel.medication.daysOfWeek.contains(day),
                                action: {}
                            )
                            .disabled(true)
                        }
                    }
                }
                
                DetailRow(title: "Start Date", value: DateUtilities.formatDate(viewModel.medication.fromDate))
                DetailRow(title: "End Date", value: DateUtilities.formatDate(viewModel.medication.toDate))
            }
            
            // Notes Section
            if let notes = viewModel.medication.notes, !notes.isEmpty {
                DetailSection(title: "Notes", icon: "note.text") {
                    HStack {
                        Text(notes)
                            .font(AppTheme.Typography.body)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    private var editModeContent: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Medication Details Section
            DetailSection(title: "Medication Details", icon: "pills.fill") {
                StyledTextField(iconName: "pill.fill", placeholder: "Medication Name", text: $viewModel.editedName, isValid: true)
                StyledTextField(iconName: "scalemass.fill", placeholder: "Dosage", text: $viewModel.editedDosage, isValid: true)
            }
            
            // Schedule Section
            DetailSection(title: "Schedule", icon: "clock.fill") {
                Button(action: { showingTimePicker = true }) {
                    HStack {
                        Image(systemName: "alarm.fill")
                            .foregroundColor(AppTheme.Colors.primary)
                        Text(DateUtilities.formatTime(viewModel.editedTimeOfDay))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding()
                    .background(AppTheme.Colors.cardBackground)
                    .cornerRadius(AppTheme.Radius.md)
                }
                
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Days")
                        .font(AppTheme.Typography.callout)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    
                    HStack(spacing: AppTheme.Spacing.sm) {
                        ForEach(1...7, id: \.self) { day in
                            WeekdayButton(
                                day: day,
                                isSelected: viewModel.editedSelectedDays.contains(day),
                                action: { viewModel.toggleDay(day) }
                            )
                        }
                    }
                }
            }
            
            // Notes Section
            DetailSection(title: "Notes", icon: "note.text") {
                VStack(spacing: AppTheme.Spacing.md) {
                    StyledTextEditor(
                        placeholder: "Add notes (optional)",
                        text: $viewModel.editedNotes
                    )
                    .frame(minHeight: 100)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - Supporting Views
struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.primary)
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            
            VStack(spacing: AppTheme.Spacing.md) {
                content
            }
            .padding()
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Radius.md)
        }
    }
}

struct DetailRow<Content: View>: View {
    let title: String
    let value: String
    let content: Content?
    
    init(title: String, value: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.content = content()
    }
    
    init(title: String, value: String) where Content == EmptyView {
        self.title = title
        self.value = value
        self.content = nil
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            Spacer()
            
            if let content = content {
                content
            } else {
                Text(value)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
    }
}
