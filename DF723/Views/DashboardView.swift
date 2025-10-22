//
//  DashboardView.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showAddIncome = false
    @State private var showAddExpense = false
    @State private var amount = ""
    @State private var note = ""
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LavaTheme.paddingLarge) {
                    // Top Navigation
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back")
                                .font(LavaTheme.captionFont)
                                .foregroundColor(LavaTheme.text.opacity(0.6))
                            Text("Dashboard")
                                .font(LavaTheme.titleFont)
                                .foregroundColor(LavaTheme.text)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .padding(.top, LavaTheme.paddingLarge)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    
                    // Total Savings Card
                    TotalSavingsCard(totalSavings: dataManager.totalSavings)
                        .padding(.horizontal, LavaTheme.paddingLarge)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : -20)
                    
                    // Monthly Overview Card
                    MonthlyOverviewCard(
                        income: dataManager.monthlyIncome,
                        expenses: dataManager.monthlyExpenses
                    )
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    
                    // Quick Actions
                    VStack(spacing: LavaTheme.paddingMedium) {
                        Text("Quick Actions")
                            .font(LavaTheme.headlineFont)
                            .foregroundColor(LavaTheme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: LavaTheme.paddingMedium) {
                            Button(action: { showAddIncome = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 30))
                                    Text("Add Income")
                                        .font(LavaTheme.captionFont)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LavaTheme.paddingLarge)
                            }
                            .buttonStyle(LavaButtonStyle(isSecondary: true))
                            
                            Button(action: { showAddExpense = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 30))
                                    Text("Add Expense")
                                        .font(LavaTheme.captionFont)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LavaTheme.paddingLarge)
                            }
                            .buttonStyle(LavaButtonStyle(isSecondary: true))
                        }
                    }
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, LavaTheme.paddingLarge)
            }
        }
        .sheet(isPresented: $showAddIncome) {
            AddTransactionSheet(
                type: .income,
                isPresented: $showAddIncome
            )
        }
        .sheet(isPresented: $showAddExpense) {
            AddTransactionSheet(
                type: .expense,
                isPresented: $showAddExpense
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animate = true
            }
        }
    }
}

struct TotalSavingsCard: View {
    let totalSavings: Double
    @State private var glowAnimate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(LavaTheme.accent)
                Text("Total Savings")
                    .font(LavaTheme.captionFont)
                    .foregroundColor(LavaTheme.text.opacity(0.7))
                Spacer()
            }
            
            Text(formatCurrency(totalSavings))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(LavaTheme.text)
            
            HStack {
                Image(systemName: "arrow.up.right")
                    .foregroundColor(LavaTheme.accent)
                Text("Growing strong")
                    .font(LavaTheme.smallFont)
                    .foregroundColor(LavaTheme.text.opacity(0.7))
            }
            
            GlowingProgressBar(progress: min(totalSavings / 10000, 1.0), height: 6)
                .padding(.top, 8)
        }
        .padding(LavaTheme.paddingLarge)
        .lavaCard()
        .overlay(
            RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusMedium)
                .stroke(LavaTheme.lavaGlow, lineWidth: glowAnimate ? 2 : 0)
                .opacity(glowAnimate ? 0.5 : 0)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowAnimate = true
            }
        }
    }
}

struct MonthlyOverviewCard: View {
    let income: Double
    let expenses: Double
    
    var difference: Double {
        income - expenses
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
            Text("This Month Overview")
                .font(LavaTheme.headlineFont)
                .foregroundColor(LavaTheme.text)
            
            VStack(spacing: LavaTheme.paddingSmall) {
                HStack {
                    HStack {
                        Circle()
                            .fill(LavaTheme.accent)
                            .frame(width: 8, height: 8)
                        Text("Income")
                            .font(LavaTheme.bodyFont)
                            .foregroundColor(LavaTheme.text.opacity(0.8))
                    }
                    Spacer()
                    Text(formatCurrency(income))
                        .font(LavaTheme.bodyFont.weight(.semibold))
                        .foregroundColor(LavaTheme.accent)
                }
                
                HStack {
                    HStack {
                        Circle()
                            .fill(LavaTheme.primaryButton)
                            .frame(width: 8, height: 8)
                        Text("Expenses")
                            .font(LavaTheme.bodyFont)
                            .foregroundColor(LavaTheme.text.opacity(0.8))
                    }
                    Spacer()
                    Text(formatCurrency(expenses))
                        .font(LavaTheme.bodyFont.weight(.semibold))
                        .foregroundColor(LavaTheme.primaryButton)
                }
                
                Divider()
                    .background(LavaTheme.highlight.opacity(0.3))
                    .padding(.vertical, 4)
                
                HStack {
                    Text("Difference")
                        .font(LavaTheme.bodyFont.weight(.semibold))
                        .foregroundColor(LavaTheme.text)
                    Spacer()
                    Text(formatCurrency(difference))
                        .font(LavaTheme.bodyFont.weight(.bold))
                        .foregroundColor(difference >= 0 ? LavaTheme.accent : LavaTheme.primaryButton)
                }
            }
        }
        .padding(LavaTheme.paddingLarge)
        .lavaCard()
    }
}

struct AddTransactionSheet: View {
    let type: TransactionType
    @Binding var isPresented: Bool
    @StateObject private var dataManager = DataManager.shared
    @State private var amount = ""
    @State private var note = ""
    
    var title: String {
        type == .income ? "Add Income" : "Add Expense"
    }
    
    var body: some View {
        ZStack {
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: LavaTheme.paddingLarge) {
                HStack {
                    Text(title)
                        .font(LavaTheme.titleFont)
                        .foregroundColor(LavaTheme.text)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(LavaTheme.text.opacity(0.6))
                    }
                }
                .padding(.horizontal, LavaTheme.paddingLarge)
                .padding(.top, LavaTheme.paddingLarge)
                
                VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(LavaTheme.captionFont)
                            .foregroundColor(LavaTheme.text.opacity(0.7))
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(LavaTheme.headlineFont)
                            .foregroundColor(LavaTheme.text)
                            .padding(LavaTheme.paddingMedium)
                            .background(
                                RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                                    .fill(LavaTheme.cardBackground)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(LavaTheme.captionFont)
                            .foregroundColor(LavaTheme.text.opacity(0.7))
                        
                        TextField("Enter note", text: $note)
                            .font(LavaTheme.bodyFont)
                            .foregroundColor(LavaTheme.text)
                            .padding(LavaTheme.paddingMedium)
                            .background(
                                RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                                    .fill(LavaTheme.cardBackground)
                            )
                    }
                }
                .padding(.horizontal, LavaTheme.paddingLarge)
                
                Spacer()
                
                Button(action: {
                    if let amountValue = Double(amount), amountValue > 0 {
                        let noteText = note.isEmpty ? (type == .income ? "Income added" : "Expense added") : note
                        dataManager.addTransaction(amount: amountValue, type: type, note: noteText)
                        isPresented = false
                    }
                }) {
                    Text("Add \(type == .income ? "Income" : "Expense")")
                }
                .buttonStyle(LavaButtonStyle())
                .disabled(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0)
                .opacity((amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0) ? 0.5 : 1.0)
                .padding(.horizontal, LavaTheme.paddingLarge)
                .padding(.bottom, LavaTheme.paddingLarge)
            }
        }
    }
}

func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencySymbol = "$"
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
}

#Preview {
    DashboardView()
}

