//
//  MedicationRowView.swift
//  MedicFix
//
//  Created by Zignuts Technolab on 19/02/25.
//

import Foundation
import SwiftUI

struct MedicationRowView: View {
    let medication: Medication
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(medication.name)
                    .font(.headline)
                
                Spacer()
                
                if !medication.isActive {
                    Text("Inactive")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Text(medication.dosage)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                // Time
                Label(
                    DateUtilities.formatTime(medication.timeOfDay),
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundColor(.blue)
                
                Spacer()
                
                // Days
                HStack(spacing: 2) {
                    ForEach(1...7, id: \.self) { day in
                        Text(DateUtilities.shortWeekdayName(day).prefix(1))
                            .font(.caption2)
                            .padding(4)
                            .background(
                                medication.daysOfWeek.contains(day) ?
                                Color.blue.opacity(0.2) : Color.clear
                            )
                            .foregroundColor(
                                medication.daysOfWeek.contains(day) ?
                                .blue : .gray
                            )
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
