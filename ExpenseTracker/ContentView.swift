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

            Button(action: { showExpenseChart.toggle() }) { 
                Image(systemName: "chart.pie")
                    .padding()
            }
            .sheet(isPresented: $showExpenseChart) {
                ExpenseChartView(classifications: classifications)
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


// MARK: - Expense Chart View

struct ExpenseChartView: View {
    var classifications: [ExpenseClassification]

    var groupedExpenses: [ExpenseCategory: Double] {
        Dictionary(grouping: classifications, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.transaction.amount } }
    }

    private var totalExpenses: Double {
        groupedExpenses.values.reduce(0, +)
    }

    var body: some View {
        VStack {
            Text("Expense Breakdown")
                .font(.headline)
                .padding()

            HStack {
                GeometryReader { geometry in
                    let radius = min(geometry.size.width, geometry.size.height) / 2
                    ZStack {
                        let angles = calculateAngles()
                        ForEach(angles.indices, id: \.self) { index in
                            let angle = angles[index]
                            PieSlice(startAngle: angle.start, endAngle: angle.end)
                                .fill(colorForCategory(angle.category))
                                .overlay(
                                    Text("\(angle.percentage, specifier: "%.1f")%")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .position(getLabelPosition(for: angle, radius: radius))
                                )
                            if angle.percentage < 5.0 {
                                drawLine(from: getLabelPosition(for: angle, radius: radius), in: geometry.size)
                                    .stroke(colorForCategory(angle.category), lineWidth: 1)
                            }
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { category in
                        HStack {
                            colorForCategory(category)
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                            Text(category.rawValue.capitalized)
                        }
                    }
                }
                .padding(.leading)
            }
        }
        .padding()
    }

    private func calculateAngles() -> [(start: Angle, end: Angle, category: ExpenseCategory, amount: Double, percentage: Double)] {
        var angles: [(Angle, Angle, ExpenseCategory, Double, Double)] = []
        var startAngle = Angle.degrees(0)
        for (category, amount) in groupedExpenses {
            let percentage = (amount / totalExpenses) * 100
            let endAngle = startAngle + Angle.degrees(360 * (amount / totalExpenses))
            angles.append((start: startAngle, end: endAngle, category: category, amount: amount, percentage: percentage))
            startAngle = endAngle
        }
        return angles
    }

    private func getLabelPosition(for angleData: (start: Angle, end: Angle, category: ExpenseCategory, amount: Double, percentage: Double), radius: CGFloat) -> CGPoint {
        let midAngle = (angleData.start + angleData.end).radians / 2
        let xOffset = cos(midAngle) * radius * 0.6
        let yOffset = sin(midAngle) * radius * 0.6
        return CGPoint(x: radius + xOffset, y: radius + yOffset)
    }

    private func drawLine(from point: CGPoint, in size: CGSize) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
        path.addLine(to: point)
        return path
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
