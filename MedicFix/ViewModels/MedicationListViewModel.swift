//
//  MedicationListViewModel.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 19/02/25.
//
import Foundation
import Combine

class MedicationListViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var isLoading = false
    
    private let storageManager = StorageManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        loadMedications()
    }
    
    func loadMedications() {
        isLoading = true
        storageManager.loadMedications { [weak self] medications in
            DispatchQueue.main.async {
                self?.medications = medications
                self?.isLoading = false
            }
        }
    }
    
    func deleteMedication(at offsets: IndexSet) {
        // Get medications to delete first
        let medicationsToDelete = offsets.map { medications[$0] }
        
        // Update storage
        storageManager.deleteMedication(at: offsets, from: medications) { [weak self] updatedMedications in
            DispatchQueue.main.async {
                self?.medications = updatedMedications
                
                // Remove notifications
                for medication in medicationsToDelete {
                    self?.notificationManager.removeNotifications(for: medication)
                }
            }
        }
    }
    
    func toggleMedicationActive(_ medication: Medication) {
        guard let index = medications.firstIndex(where: { $0.id == medication.id }) else {
            return
        }

        var updatedMedication = medications[index]

        // 🚨 Prevent reactivating expired medications
        let today = Date()
        if updatedMedication.isActive == false, today > updatedMedication.toDate {
            return
        }

        updatedMedication.isActive.toggle()  // Toggle the isActive property

        // Update Firestore and update local array after completion
        storageManager.updateMedication(updatedMedication, in: medications) { [weak self] updatedMedications in
            DispatchQueue.main.async {
                self?.medications = updatedMedications

                // Manage notifications based on isActive status
                if updatedMedication.isActive {
                    self?.notificationManager.scheduleNotifications(for: updatedMedication)
                } else {
                    self?.notificationManager.removeNotifications(for: updatedMedication)
                }
            }
        }
    }
    
    func getTodayMedications() -> [Medication] {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let currentDate = Date()
        
        return medications.filter { medication in
            medication.isActive &&
            medication.daysOfWeek.contains(today) &&
            currentDate >= medication.fromDate && currentDate <= medication.toDate // Ensure medication is within valid date range
        }
    }
}
