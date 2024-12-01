//
//  ExpenseClassification.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-12-01.
//

import Foundation

struct ExpenseClassification {
    let transaction: Transaction
    let category: ExpenseCategory
}

enum ExpenseCategory: String, CaseIterable {
    case food, entertainment, utilities, transportation, other
}
