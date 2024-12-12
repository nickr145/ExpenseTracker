//
//  Account.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-12-01.
//

import Foundation

struct Account {
    let name: String
    var transactions: [Transaction]
    
    var balance: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
}
