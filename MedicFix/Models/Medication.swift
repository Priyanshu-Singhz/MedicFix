//
//  Medication.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
struct Medication: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dosage: String
    var timeOfDay: Date
    var notes: String?
    var daysOfWeek: [Int]  // 1-7 representing days (1 = Sunday)
    let fromDate: Date
    let toDate: Date
    var isActive: Bool = true
    
    // Helper method to check if medication is due today
    func isDueToday() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        let weekday = calendar.component(.weekday, from: today)
        
        return isActive && daysOfWeek.contains(weekday) &&
               today >= fromDate && today <= toDate
    }
}
