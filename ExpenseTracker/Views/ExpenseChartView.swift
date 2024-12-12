//
//  ExpenseChartView.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-12-12.
//

import SwiftUI
import Charts

struct ExpenseChartView: View {
    var classifications: [ExpenseClassification]

    var groupedExpenses: [ExpenseCategory: Double] {
        Dictionary(grouping: classifications, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.transaction.amount } }
            .filter { $0.value != 0 }
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
                    .foregroundStyle(amount < 0 ? .red : (amount > 0 ? .green : .black))
                }
            }
            .frame(height: 300)
            .padding()

            List(groupedExpenses.sorted(by: { $0.key.rawValue < $1.key.rawValue }), id: \.key) { category, amount in
                HStack {
                    Text(category.rawValue.capitalized)
                    Spacer()
                    Text(String(format: "$%.2f", amount))
                        .foregroundStyle(amount < 0 ? .red : (amount > 0 ? .green : .black))
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    ExpenseChartView()
//}
