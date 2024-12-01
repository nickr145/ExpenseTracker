//
//  Date.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-12-01.
//

import Foundation

extension Date {
    func isInCurrentMonth() -> Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        let transactionMonth = calendar.component(.month, from: self)
        let transactionYear = calendar.component(.year, from: self)
        
        return transactionMonth == currentMonth && transactionYear == currentYear
    }
}
