//
//  AddMedicationViewModel.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
import Combine

class AddMedicationViewModel: ObservableObject {
    // Form fields
    @Published var medicationName: String = ""
    @Published var dosage: String = ""
    @Published var timeOfDay: Date = Date()
    @Published var notes: String = ""
    @Published var selectedDays: Set<Int> = []
    
    @Published var fromDate: Date = Date()
    @Published var toDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    // Validation
    @Published var nameIsValid: Bool = false
    @Published var dosageIsValid: Bool = false
    @Published var daysIsValid: Bool = false
    @Published var dateRangeIsValid: Bool = true
    @Published var formIsValid: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let storageManager = StorageManager.shared
    private let notificationManager = NotificationManager.shared

    init() {
        setupValidation()
    }

    private func setupValidation() {
        // Name validation
        $medicationName
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: \.nameIsValid, on: self)
            .store(in: &cancellables)

        // Dosage validation
        $dosage
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: \.dosageIsValid, on: self)
            .store(in: &cancellables)

        // Days validation
        $selectedDays
            .map { !$0.isEmpty }
            .assign(to: \.daysIsValid, on: self)
            .store(in: &cancellables)

        // Date range validation (toDate must be later than or equal to fromDate)
        Publishers.CombineLatest($fromDate, $toDate)
            .map { from, to in to >= from }
            .assign(to: \.dateRangeIsValid, on: self)
            .store(in: &cancellables)

        // Form validation (all fields must be valid)
        Publishers.CombineLatest4($nameIsValid, $dosageIsValid, $daysIsValid, $dateRangeIsValid)
            .map { nameValid, dosageValid, daysValid, dateValid in
                return nameValid && dosageValid && daysValid && dateValid
            }
            .assign(to: \.formIsValid, on: self)
            .store(in: &cancellables)
    }

    func toggleDay(_ day: Int) {
        print("Toggling day: \(day), Current selectedDays: \(selectedDays)")
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
        print("After toggle, selectedDays: \(selectedDays)")
    }

    func createMedication() -> Medication {
        return Medication(
            name: medicationName.trimmingCharacters(in: .whitespacesAndNewlines),
            dosage: dosage.trimmingCharacters(in: .whitespacesAndNewlines),
            timeOfDay: timeOfDay,
            notes: notes.isEmpty ? nil : notes,
            daysOfWeek: Array(selectedDays),
            fromDate: fromDate,
            toDate: toDate
        )
    }

    func saveMedication(medications: [Medication], completion: @escaping ([Medication]) -> Void) {
        let newMedication = createMedication()

        storageManager.addMedication(newMedication, to: medications) { updatedMedications in
            DispatchQueue.main.async { [self] in
                notificationManager.scheduleNotifications(for: newMedication)
                completion(updatedMedications)
            }
        }
        NotificationManager.shared.scheduleNotifications(for: newMedication)
    }

    func resetForm() {
        medicationName = ""
        dosage = ""
        timeOfDay = Date()
        notes = ""
        selectedDays = []
        fromDate = Date()
        toDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }
}
