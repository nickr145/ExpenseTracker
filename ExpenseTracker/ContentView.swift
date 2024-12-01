//
//  ContentView.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-10-25.
//

import SwiftUI
import Charts

// MARK: - Home View

struct HomeView: View {
    @State private var accounts = [
        Account(name: "Chequing Account", balance: 5000.0, transactions: [
            Transaction(date: Date(), amount: -50.0, name: "Groceries"),
            Transaction(date: Date(), amount: -100.0, name: "Electricity Bill")
        ]),
        Account(name: "Credit Card", balance: -1500.0, transactions: [
            Transaction(date: Date(), amount: -20.0, name: "Cinema"),
            Transaction(date: Date(), amount: -30.0, name: "Fuel")
        ])
    ]

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to CIBC Mobile")
                    .font(.largeTitle)
                    .padding()
                
                List(accounts.indices, id: \.self) { index in
                    NavigationLink(destination: AccountDetailView(account: $accounts[index])) {
                        HStack {
                            Text(accounts[index].name)
                            Spacer()
                            Text(String(format: "$%.2f", accounts[index].balance))
                                .foregroundColor(accounts[index].balance >= 0 ? .green : .red)
                        }
                    }
                }
            }
            .navigationTitle("Accounts")
        }
    }
}

// MARK: - Account Detail View

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

struct AccountDetailView: View {
    @Binding var account: Account
    @State private var showExpenseChart = false
    @State private var showAddTransactionForm = false

    var classifications: [ExpenseClassification] {
        account.transactions.filter { $0.date.isInCurrentMonth() }.map { transaction in
            let category: ExpenseCategory = {
                switch transaction.name.lowercased() {
                case "groceries": return .food
                case "cinema": return .entertainment
                case "electricity bill": return .utilities
                case "fuel": return .transportation
                default: return .other
                }
            }()
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

// MARK: - Add Transaction Form View

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
        account.balance += amountValue
    }
}




// MARK: - Expense Chart View

struct ExpenseChartView: View {
    var classifications: [ExpenseClassification]

    var groupedExpenses: [ExpenseCategory: Double] {
        Dictionary(grouping: classifications, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + abs($1.transaction.amount) } }
    }

    var body: some View {
        VStack {
            Text("Expense Breakdown")
                .font(.headline)
                .padding()

            Chart {
                ForEach(groupedExpenses.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { category, amount in
                    BarMark(
                        x: .value("Category", category.rawValue.capitalized),
                        y: .value("Amount", amount)
                    )
                    .foregroundStyle(colorForCategory(category))
                }
            }
            .frame(height: 300)
            .padding()

            List(groupedExpenses.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { category, amount in
                HStack {
                    Text(category.rawValue.capitalized)
                    Spacer()
                    Text(String(format: "$%.2f", amount))
                        .foregroundColor(colorForCategory(category))
                }
            }
        }
        .padding()
    }

    private func colorForCategory(_ category: ExpenseCategory) -> Color {
        switch category {
        case .food: return .green
        case .entertainment: return .blue
        case .utilities: return .orange
        case .transportation: return .purple
        case .other: return .gray
        }
    }
}

#Preview {
    HomeView()
}
