//
//  AddTransactionForm.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-12-12.
//

import SwiftUI

struct AddTransactionForm: View {
    @Environment(\.dismiss) var dismiss
    @Binding var account: Account

    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Transaction Details")) {
                    TextField("Name", text: $name)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTransaction()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveTransaction() {
        guard let amountValue = Double(amount) else { return }
        let newTransaction = Transaction(date: date, amount: amountValue, name: name)
        account.transactions.append(newTransaction)
    }
}

//#Preview {
//    AddTransactionForm()
//}
