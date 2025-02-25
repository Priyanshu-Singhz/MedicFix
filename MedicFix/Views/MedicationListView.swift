//
//  MedicationListView.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 19/02/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct MedicationListView: View {
    @StateObject private var viewModel = MedicationListViewModel()
    @State private var showingAddSheet = false
    @State private var showingPermissionAlert = false
    @State private var isSidebarVisible = false // Added state for sidebar
    @State private var animateGradient = false
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.85, green: 0.93, blue: 1.0, alpha: 1)), // Light Sky Blue
                        Color(#colorLiteral(red: 0.95, green: 0.98, blue: 1.0, alpha: 1))  // Very Light Blue with White Tint
                    ]),
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: true)) {
                        animateGradient.toggle()
                    }
                }
                
                // Main content
                VStack(spacing: 0) {
                    // Custom Header with sidebar toggle
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    isSidebarVisible.toggle()
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                            }
                            
                            Text("Medication Reminder")
                                .font(AppTheme.Typography.title)
                                .foregroundColor(AppTheme.Colors.textPrimary)
                        }
                        
                        Text("Stay on track with your medications")
                            .font(AppTheme.Typography.callout)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.md)
                    
                    ScrollView {
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Today's medications section
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                                HStack {
                                    Label("Today's Medications", systemImage: "calendar")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(formattedCurrentDate())
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .padding(.vertical, AppTheme.Spacing.xs)
                                        .padding(.horizontal, AppTheme.Spacing.sm)
                                        .background(AppTheme.Colors.secondaryBackground)
                                        .cornerRadius(AppTheme.Radius.sm)
                                }
                                
                                let todayMeds = viewModel.getTodayMedications()
                                if todayMeds.isEmpty {
                                    EmptyStateView(
                                        icon: "pills",
                                        title: "No medications for today",
                                        subtitle: "Enjoy your day medication-free!"
                                    )
                                } else {
                                    LazyVStack(spacing: AppTheme.Spacing.md) {
                                        ForEach(todayMeds) { medication in
                                            NavigationLink(destination: MedicationDetailView(
                                                medication: medication,
                                                medications: $viewModel.medications
                                            )) {
                                                EnhancedMedicationRowView(medication: medication)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            
                            // All medications section
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                                HStack {
                                    Label("All Medications", systemImage: "list.bullet")
                                        .font(AppTheme.Typography.headline)
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.medications.count)")
                                        .font(AppTheme.Typography.caption)
                                        .foregroundColor(.white)
                                        .padding(.vertical, AppTheme.Spacing.xs)
                                        .padding(.horizontal, AppTheme.Spacing.sm)
                                        .background(AppTheme.Colors.primary)
                                        .cornerRadius(AppTheme.Radius.circular)
                                }
                                
                                if viewModel.medications.isEmpty {
                                    EmptyStateView(
                                        icon: "pill",
                                        title: "No medications added",
                                        subtitle: "Tap the + button to add your medications"
                                    )
                                } else {
                                    LazyVStack(spacing: AppTheme.Spacing.md) {
                                        ForEach(viewModel.medications) { medication in
                                            NavigationLink(destination: MedicationDetailView(
                                                medication: medication,
                                                medications: $viewModel.medications
                                            )) {
                                                EnhancedMedicationRowView(medication: medication)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .onDelete(perform: deleteMedication)
                                    }
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                            .padding(.bottom, AppTheme.Spacing.xl)
                        }
                        .padding(.top, AppTheme.Spacing.md)
                    }
                }
                
                // Sidebar overlay
                if isSidebarVisible {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            SidebarView(isSidebarVisible: $isSidebarVisible)
                            
                            Spacer()
                        }
                        .background(Color.black.opacity(0.4))
                        .offset(x: isSidebarVisible ? 0 : -geometry.size.width)
                        .animation(.easeInOut(duration: 0.3), value: isSidebarVisible)
                        .onTapGesture {
                            withAnimation {
                                isSidebarVisible = false
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                Button(action: {
                    requestPermissionAndAddMedication()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(AppTheme.Colors.accent)
                        .cornerRadius(AppTheme.Radius.circular)
                        .shadow(
                            color: AppTheme.Colors.accent.opacity(0.3),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                }
                    .padding(AppTheme.Spacing.xl),
                alignment: .bottomTrailing
            )
            .sheet(isPresented: $showingAddSheet) {
                AddMedicationView(medications: $viewModel.medications)
            }
            .alert(isPresented: $showingPermissionAlert) {
                Alert(
                    title: Text("Notification Permission Required"),
                    message: Text("Please enable notifications in Settings to receive medication reminders."),
                    primaryButton: .default(Text("Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // Helper functions
    private func requestPermissionAndAddMedication() {
        NotificationManager.shared.requestPermission { granted in
            if granted {
                showingAddSheet = true
            } else {
                showingPermissionAlert = true
            }
        }
    }
    
    private func deleteMedication(at indexSet: IndexSet) {
        viewModel.deleteMedication(at: indexSet)
    }
    
    private func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - EnhancedMedicationRowView
struct EnhancedMedicationRowView: View {
    let medication: Medication
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Icon container
            ZStack {
                Circle()
                    .fill(
                        medication.isActive
                        ? AppTheme.Colors.secondaryBackground
                        : Color.gray.opacity(0.1)
                    )
                
                Image(systemName: "pill.fill")
                    .font(.system(size: 18))
                    .foregroundColor(
                        medication.isActive
                        ? AppTheme.Colors.primary
                        : AppTheme.Colors.textTertiary
                    )
            }
            .frame(width: 46, height: 46)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(medication.name)
                        .font(AppTheme.Typography.headline)
                        .foregroundColor(
                            medication.isActive
                            ? AppTheme.Colors.textPrimary
                            : AppTheme.Colors.textSecondary
                        )
                    
                    if !medication.isActive {
                        Text("Inactive")
                            .font(AppTheme.Typography.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .cornerRadius(AppTheme.Radius.sm)
                    }
                }
                
                Text(medication.dosage)
                    .font(AppTheme.Typography.callout)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                
                HStack(spacing: AppTheme.Spacing.md) {
                    // Time
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text(DateUtilities.formatTime(medication.timeOfDay))
                            .font(AppTheme.Typography.caption)
                    }
                    .foregroundColor(
                        medication.isActive
                        ? AppTheme.Colors.primary
                        : AppTheme.Colors.textTertiary
                    )
                    
                    // Days
                    HStack(spacing: 2) {
                        ForEach(1...7, id: \.self) { day in
                            Text(DateUtilities.shortWeekdayName(day).prefix(1))
                                .font(.system(size: 10, weight: .medium))
                                .frame(width: 16, height: 16)
                                .background(
                                    medication.daysOfWeek.contains(day)
                                    ? (medication.isActive ? AppTheme.Colors.primary : Color.gray)
                                    : Color.clear
                                )
                                .foregroundColor(
                                    medication.daysOfWeek.contains(day)
                                    ? Color.white
                                    : AppTheme.Colors.textTertiary
                                )
                                .cornerRadius(AppTheme.Radius.sm)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textTertiary)
        }
        .padding(AppTheme.Spacing.md)
        .background(AppTheme.Colors.cardBackground)
        .cornerRadius(AppTheme.Radius.md)
        .shadow(
            color: AppTheme.Shadows.small.color,
            radius: AppTheme.Shadows.small.radius,
            x: AppTheme.Shadows.small.x,
            y: AppTheme.Shadows.small.y
        )
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(AppTheme.Colors.primary.opacity(0.7))
                .padding(.bottom, AppTheme.Spacing.sm)
            
            Text(title)
                .font(AppTheme.Typography.headline)
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Text(subtitle)
                .font(AppTheme.Typography.callout)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.xl)
        .background(AppTheme.Colors.secondaryBackground.opacity(0.5))
        .cornerRadius(AppTheme.Radius.md)
    }
}
