//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-12-01.
//

import Foundation

struct Transaction: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let name: String
}
