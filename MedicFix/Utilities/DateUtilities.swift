//
//  DateUtilities.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
struct DateUtilities {
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    
    static func weekdayName(_ weekdayNumber: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        // Adjust index (calendar weekdays are 1-based, arrays are 0-based)
        let adjustedIndex = weekdayNumber - 1
        guard adjustedIndex >= 0 && adjustedIndex < weekdaySymbols.count else {
            return ""
        }
        return weekdaySymbols[adjustedIndex]
    }
    
    static func shortWeekdayName(_ weekdayNumber: Int) -> String {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.shortWeekdaySymbols
        let adjustedIndex = weekdayNumber - 1
        guard adjustedIndex >= 0 && adjustedIndex < weekdaySymbols.count else {
            return ""
        }
        return weekdaySymbols[adjustedIndex]
    }
}
