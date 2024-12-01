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

enum ExpenseCategory: String, CaseIterable, Comparable {
    case food
    case entertainment
    case health
    case housing
    case income
    case investments
    case savings
    case utilities
    case shopping
    case transfers
    case other
    
    static func < (lhs: ExpenseCategory, rhs: ExpenseCategory) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

