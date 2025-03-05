//
//  AddMedicationView.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
import SwiftUI

struct AddMedicationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AddMedicationViewModel()
    @Binding var medications: [Medication]
    @State private var showingDatePicker = false
    @State private var showingEndDatePicker = false
    @State private var showingTimePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.background
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        Text("Add Medication")
                            .font(AppTheme.Typography.title)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Text("Set up a new medication reminder")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.md)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.xl) {
                            // Medication details section
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                                SectionHeader(title: "Medication Details")
                                
                                VStack(spacing: AppTheme.Spacing.md) {
                                    StyledTextField(iconName: "pill.fill", placeholder: "Medication Name", text: $viewModel.medicationName, isValid: viewModel.nameIsValid)
                                    
                                    StyledTextField(iconName: "scalemass.fill", placeholder: "Dosage (e.g., 10mg)", text: $viewModel.dosage, isValid: viewModel.dosageIsValid)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            // Reminder time section
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                                SectionHeader(title: "Reminder Time")

                                Button(action: { showingTimePicker.toggle() }) {
                                    HStack {
                                        Image(systemName: "alarm.fill")
                                            .font(.system(size: 18))
                                            .frame(width: 24)
                                            .foregroundColor(AppTheme.Colors.primary)
                                        
                                        Text(viewModel.timeOfDay, formatter: timeFormatter)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                    .padding()
                                    .background(AppTheme.Colors.cardBackground)
                                    .cornerRadius(AppTheme.Radius.md)
                                }
                                
                                if showingTimePicker {
                                    DatePicker("", selection: $viewModel.timeOfDay, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .background(AppTheme.Colors.cardBackground)
                                        .cornerRadius(AppTheme.Radius.md)
                                        .padding()
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)

                            // Days of Week section
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                                SectionHeader(title: "Days of Week")
                                
                                VStack(alignment: .leading) { // Ensure alignment
                                    HStack(spacing: AppTheme.Spacing.sm) {
                                        ForEach(1...7, id: \.self) { day in
                                            WeekdayButton(
                                                day: day,
                                                isSelected: viewModel.selectedDays.contains(day),
                                                action: { viewModel.toggleDay(day) }
                                            )
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading) // Ensure HStack takes full width
                                .padding(.horizontal, AppTheme.Spacing.sm)
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)

                            // Duration Section with Start & End Date Pickers
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                                SectionHeader(title: "Duration")

                                // Start Date Button
                                Button(action: { showingDatePicker.toggle() }) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .font(.system(size: 18))
                                            .frame(width: 24)
                                            .foregroundColor(AppTheme.Colors.primary)
                                        
                                        Text("Start Date: \(viewModel.fromDate, formatter: dateFormatter)")
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                    .padding()
                                    .background(AppTheme.Colors.cardBackground)
                                    .cornerRadius(AppTheme.Radius.md)
                                }

                                // Start Date Picker (Inline)
                                if showingDatePicker {
                                    DatePicker("", selection: $viewModel.fromDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .background(AppTheme.Colors.cardBackground)
                                        .cornerRadius(AppTheme.Radius.md)
                                        .padding()
                                }

                                // End Date Button
                                Button(action: { showingEndDatePicker.toggle() }) {
                                    HStack {
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.system(size: 18))
                                            .frame(width: 24)
                                            .foregroundColor(AppTheme.Colors.primary)
                                        
                                        Text("End Date: \(viewModel.toDate, formatter: dateFormatter)")
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                    .padding()
                                    .background(AppTheme.Colors.cardBackground)
                                    .cornerRadius(AppTheme.Radius.md)
                                }

                                // End Date Picker (Inline)
                                if showingEndDatePicker {
                                    DatePicker("", selection: $viewModel.toDate, in: viewModel.fromDate..., displayedComponents: .date)
                                        .datePickerStyle(GraphicalDatePickerStyle())
                                        .background(AppTheme.Colors.cardBackground)
                                        .cornerRadius(AppTheme.Radius.md)
                                        .padding()
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)

                            
                            // Additional Notes section
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                                SectionHeader(title: "Additional Notes")
                                
                                StyledTextField(iconName: "square.and.pencil", placeholder: "Notes (optional)", text: $viewModel.notes, isValid: true)
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            // Action buttons
                            HStack(spacing: AppTheme.Spacing.md) {
                                Button(action: {
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Cancel").frame(maxWidth: .infinity)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                
                                Button(action: {
                                    viewModel.saveMedication(medications: medications) { updatedMedications in
                                        self.medications = updatedMedications
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    Text("Save Medication").frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PrimaryButtonStyle(isEnabled: viewModel.formIsValid))
                                .disabled(!viewModel.formIsValid)
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.top, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.xxl)
                        }
                        .padding(.top, AppTheme.Spacing.md)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

// MARK: - Supporting Components
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(AppTheme.Typography.subtitle)
            .foregroundColor(AppTheme.Colors.textPrimary)
        
    }
}

struct StyledTextField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var isValid: Bool = true
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: iconName)
                .font(.system(size: 18))
                .frame(width: 24)
                .foregroundColor(
                    isValid || text.isEmpty
                    ? AppTheme.Colors.primary
                    : AppTheme.Colors.error
                )
            
            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .autocapitalization(.words)
        }
        .padding(.vertical, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                .stroke(
                    !text.isEmpty && !isValid
                    ? AppTheme.Colors.error
                    : Color.clear,
                    lineWidth: 1.5
                )
        )
        .cornerRadius(AppTheme.Radius.md)
    }
}

struct StyledTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(AppTheme.Typography.body)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding(AppTheme.Spacing.sm)
                .frame(minHeight: 120)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(AppTheme.Typography.body)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .padding(AppTheme.Spacing.lg)
                    .allowsHitTesting(false)
            }
        }
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.Radius.md)
    }
}

struct WeekdayButton: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.xxs) {
                Text(DateUtilities.shortWeekdayName(day).prefix(1))
                    .font(.system(size: 14, weight: .bold))
                Text(DateUtilities.shortWeekdayName(day).dropFirst(1))
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            .frame(width: 45, height: 45)
            .background(
                isSelected
                ? AppTheme.Colors.primary
                : AppTheme.Colors.secondaryBackground
            )
            .cornerRadius(AppTheme.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(
                        isSelected
                        ? AppTheme.Colors.primaryDark
                        : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
