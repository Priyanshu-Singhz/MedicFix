//
//  MedicationDetailViewModel.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 19/02/25.
//
import Foundation
import Combine

@MainActor
class MedicationDetailViewModel: ObservableObject {
    @Published var medication: Medication
    @Published var isEditing: Bool = false
    
    // Edited values
    @Published var editedName: String = ""
    @Published var editedDosage: String = ""
    @Published var editedTimeOfDay: Date = Date()
    @Published var editedNotes: String = ""
    @Published var editedSelectedDays: Set<Int> = []
    
    private let storageManager = StorageManager.shared
    private let notificationManager = NotificationManager.shared
    
    init(medication: Medication) {
        self.medication = medication
        populateEditFields()
    }
    
    func populateEditFields() {
        editedName = medication.name
        editedDosage = medication.dosage
        editedTimeOfDay = medication.timeOfDay
        editedNotes = medication.notes ?? ""
        editedSelectedDays = Set(medication.daysOfWeek)
    }
    
    func toggleDay(_ day: Int) {
        if editedSelectedDays.contains(day) {
            editedSelectedDays.remove(day)
        } else {
            editedSelectedDays.insert(day)
        }
    }
    
    func saveMedicationChanges(in medications: [Medication], completion: @escaping ([Medication]) -> Void) {
        let updatedMedication = Medication(
            id: medication.id,
            name: editedName.trimmingCharacters(in: .whitespacesAndNewlines),
            dosage: editedDosage.trimmingCharacters(in: .whitespacesAndNewlines),
            timeOfDay: editedTimeOfDay,
            notes: editedNotes.isEmpty ? nil : editedNotes,
            daysOfWeek: Array(editedSelectedDays).sorted(),  // Ensure consistent order
            fromDate: medication.fromDate,  // Ensure we keep the original date range
            toDate: medication.toDate,
            isActive: medication.isActive
        )

        // Update Firestore and update local medications array after completion
        storageManager.updateMedication(updatedMedication, in: medications) { [weak self] updatedMedications in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.medication = updatedMedication  // Update local reference

                // Manage notifications based on isActive status
                if updatedMedication.isActive {
                    self.notificationManager.scheduleNotifications(for: updatedMedication)
                } else {
                    self.notificationManager.removeNotifications(for: updatedMedication)
                }

                // Call the completion handler
                completion(updatedMedications)
            }
        }
    }
    func deleteMedication(from medications: [Medication], completion: @escaping ([Medication]) -> Void) {
        guard let collection = storageManager.medicationsCollection else {
            completion(medications)
            return
        }
        
        let medicationToDelete = self.medication // Get the current medication

        collection.document(medicationToDelete.id.uuidString).delete { error in
            if let error = error {
                print("Error deleting medication: \(error.localizedDescription)")
                completion(medications) // Return unchanged list if deletion fails
                return
            }
            
            // Remove the deleted medication from the list
            let updatedMedications = medications.filter { $0.id != medicationToDelete.id }
            
            // Complete with updated list
            DispatchQueue.main.async {
                completion(updatedMedications)
            }
        }
    }

}
