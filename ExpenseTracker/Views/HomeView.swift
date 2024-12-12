//
//  HomeView.swift
//  ExpenseTracker
//
//  Created by Nicholas Rebello on 2024-10-25.
//

import SwiftUI
import Charts

struct HomeView: View {
    @State private var accounts = [
        Account(name: "Chequing Account", transactions: [
            Transaction(date: Date(), amount: 500.0, name: "CIBC Pay"),
            Transaction(date: Date(), amount: -50.0, name: "Groceries"),
            Transaction(date: Date(), amount: -100.0, name: "Electricity Bill")
        ]),
        Account(name: "Credit Card", transactions: [
            Transaction(date: Date(), amount: 20.0, name: "Cinema"),
            Transaction(date: Date(), amount: 30.0, name: "Fuel")
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

#Preview {
    HomeView()
}
