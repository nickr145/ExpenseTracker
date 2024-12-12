//
//  AccountDetailView.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-12-12.
//

import SwiftUI

struct AccountDetailView: View {
    @Binding var account: Account
    @State private var showExpenseChart = false
    @State private var showAddTransactionForm = false

    var classifications: [ExpenseClassification] {
        let categoryKeywords: [ExpenseCategory: [String]] = [
            .food: ["grocery", "restaurant", "food", "snack", "meal", "café", "takeout", "groceries", "kibo", "boba", "the alley", "mcdonald's"],
            .entertainment: ["movie", "concert", "theater", "sports", "amusement", "cinema"],
            .health: ["doctor", "pharmacy", "health", "medicine", "hospital", "clinic"],
            .housing: ["rent", "mortgage"],
            .income: ["salary", "income", "wages", "bonus", "pay", "net pay"],
            .investments: ["stocks", "investment", "bonds", "mutual funds"],
            .savings: ["savings", "deposits", "interest", "bonds", "mutual"],
            .shopping: ["shopping", "retail", "online", "marketplace"],
            .transfers: ["transfer", "send", "deposit", "withdrawal", "e-transfer"],
            .utilities: ["electricity", "water", "bill"],
            .other: [] // Default category
        ]

        return account.transactions.filter { $0.date.isInCurrentMonth() }.map { transaction in
            let normalizedName = transaction.name.lowercased()
            let category: ExpenseCategory = categoryKeywords.first { (category, keywords) in
                keywords.contains(where: { normalizedName.contains($0) })
            }?.key ?? .other
            return ExpenseClassification(transaction: transaction, category: category)
        }
    }


    var body: some View {
        VStack {
            Text(account.name)
                .font(.title)
                .padding()

            Text("Balance: \(String(format: "$%.2f", account.balance))")
                .font(.headline)
                .foregroundColor(account.balance >= 0 ? .green : .red)
            
            HStack {
                
                Button(action: { showExpenseChart.toggle() }) {
                    Image(systemName: "chart.pie")
                        .padding()
                }
                .sheet(isPresented: $showExpenseChart) {
                    ExpenseChartView(classifications: classifications)
                }
                Button(action: { showAddTransactionForm.toggle() }) {
                    Image(systemName: "plus.circle")
                        .padding()
                }
                .sheet(isPresented: $showAddTransactionForm) {
                    AddTransactionForm(account: $account)
                }
                
            }

            List(account.transactions.filter { $0.date.isInCurrentMonth() }) { transaction in
                VStack(alignment: .leading) {
                    Text(transaction.name)
                    Text("\(transaction.date.description)")
                    Text("Amount: \(String(format: "$%.2f", transaction.amount))")
                        .foregroundColor(transaction.amount >= 0 ? .green : .red)
                }
            }
        }
    }
}

//#Preview {
//    AccountDetailView()
//}
