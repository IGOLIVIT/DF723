//
//  HistoryView.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI
import Charts

struct HistoryView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: LavaTheme.paddingMedium) {
                    Text("History")
                        .font(LavaTheme.titleFont)
                        .foregroundColor(LavaTheme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, LavaTheme.paddingLarge)
                        .padding(.top, LavaTheme.paddingLarge)
                    
                    // Tab Selector
                    HStack(spacing: LavaTheme.paddingSmall) {
                        TabButton(title: "Balance", isSelected: selectedTab == 0) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = 0
                            }
                        }
                        
                        TabButton(title: "Expenses", isSelected: selectedTab == 1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = 1
                            }
                        }
                        
                        TabButton(title: "Savings", isSelected: selectedTab == 2) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = 2
                            }
                        }
                    }
                    .padding(.horizontal, LavaTheme.paddingLarge)
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -20)
                
                // Content
                ScrollView {
                    VStack(spacing: LavaTheme.paddingLarge) {
                        // Always show chart card, even if empty
                        VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                            Text(chartTitle)
                                .font(LavaTheme.headlineFont)
                                .foregroundColor(LavaTheme.text)
                            
                            BalanceChart(
                                data: dataManager.getChartData(),
                                selectedTab: selectedTab
                            )
                            .frame(height: 220)
                        }
                        .padding(LavaTheme.paddingLarge)
                        .lavaCard()
                        .padding(.horizontal, LavaTheme.paddingLarge)
                        .opacity(animate ? 1 : 0)
                        
                        // Recent Transactions
                        if !dataManager.transactions.isEmpty {
                            VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                                Text("Recent Transactions")
                                    .font(LavaTheme.headlineFont)
                                    .foregroundColor(LavaTheme.text)
                                
                                ForEach(dataManager.getRecentTransactions(limit: 10)) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                            .padding(LavaTheme.paddingLarge)
                            .lavaCard()
                            .padding(.horizontal, LavaTheme.paddingLarge)
                            .opacity(animate ? 1 : 0)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.top, LavaTheme.paddingLarge)
                    .padding(.bottom, LavaTheme.paddingLarge)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animate = true
            }
        }
    }
    
    var chartTitle: String {
        switch selectedTab {
        case 0: return "Daily Balance"
        case 1: return "Daily Expenses"
        case 2: return "Daily Savings"
        default: return "Balance"
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LavaTheme.bodyFont)
                .foregroundColor(isSelected ? LavaTheme.text : LavaTheme.text.opacity(0.6))
                .padding(.horizontal, LavaTheme.paddingLarge)
                .padding(.vertical, LavaTheme.paddingSmall)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                                .fill(LavaTheme.lavaGlow)
                        } else {
                            RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                                .fill(LavaTheme.cardBackground)
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                        .stroke(isSelected ? Color.clear : LavaTheme.highlight.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BalanceChart: View {
    let data: [DailyBalance]
    let selectedTab: Int
    @State private var animateChart = false
    
    var chartData: [(Date, Double)] {
        let sortedData = data.sorted { $0.date < $1.date }
        switch selectedTab {
        case 0: return sortedData.map { ($0.date, $0.balance) }
        case 1: return sortedData.map { ($0.date, $0.expenses) }
        case 2: return sortedData.map { ($0.date, $0.savings) }
        default: return sortedData.map { ($0.date, $0.balance) }
        }
    }
    
    var hasNonZeroData: Bool {
        chartData.contains { $0.1 != 0 }
    }
    
    var body: some View {
        ZStack {
            // Glow background
            RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusSmall)
                .fill(LavaTheme.lavaGlow.opacity(0.1))
                .blur(radius: 20)
            
            if chartData.isEmpty || !hasNonZeroData {
                // Empty state
                VStack(spacing: LavaTheme.paddingSmall) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 40))
                        .foregroundColor(LavaTheme.text.opacity(0.3))
                    Text(chartData.isEmpty ? "No data yet" : "All values are zero")
                        .font(LavaTheme.bodyFont)
                        .foregroundColor(LavaTheme.text.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Use simple chart for all iOS versions
                SimpleLegacyChart(data: chartData, animate: animateChart)
                    .frame(height: 180)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateChart = true
            }
        }
        .onChange(of: selectedTab) { _ in
            animateChart = false
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                animateChart = true
            }
        }
    }
}

struct SimpleLegacyChart: View {
    let data: [(Date, Double)]
    let animate: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.map { $0.1 }.max() ?? 1
            let minValue = data.map { $0.1 }.min() ?? 0
            let range = max(maxValue - minValue, maxValue * 0.2) // At least 20% range for better visibility
            
            ZStack {
                // Background
                Rectangle()
                    .fill(LavaTheme.cardBackground.opacity(0.3))
                
                // Grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Divider()
                            .background(LavaTheme.highlight.opacity(0.2))
                        if i < 4 { Spacer() }
                    }
                }
                
                if data.count == 1 {
                    // Special case: Single data point - show as bar
                    let item = data[0]
                    let value = item.1
                    let displayRange = max(value * 1.2, 100) // Add 20% padding above value
                    let normalizedValue = value / displayRange
                    let barHeight = max(geometry.size.height * CGFloat(normalizedValue), 50) // Minimum 50pt
                    let barWidth: CGFloat = 80
                    
                    VStack(spacing: 12) {
                        Spacer()
                        
                        VStack(spacing: 8) {
                            // Value on top
                            Text("$\(Int(value))")
                                .font(LavaTheme.bodyFont.weight(.bold))
                                .foregroundColor(LavaTheme.accent)
                            
                            // Bar
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [LavaTheme.primaryButton, LavaTheme.primaryButton.opacity(0.7)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: barWidth, height: barHeight)
                                .shadow(color: LavaTheme.primaryButton.opacity(0.6), radius: 15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(LavaTheme.accent.opacity(0.5), lineWidth: 2)
                                )
                            
                            // Today label
                            Text("Today")
                                .font(LavaTheme.captionFont)
                                .foregroundColor(LavaTheme.text.opacity(0.6))
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    // Multiple data points - show as line chart
                    
                    // Line path
                    Path { path in
                        guard !data.isEmpty else { return }
                        
                        let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                        
                        for (index, item) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalizedValue = (item.1 - minValue) / range
                            let y = geometry.size.height * (1 - CGFloat(normalizedValue))
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(LavaTheme.primaryButton, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .shadow(color: LavaTheme.primaryButton.opacity(0.6), radius: 10)
                    
                    // Area fill
                    Path { path in
                        guard !data.isEmpty else { return }
                        
                        let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                        
                        path.move(to: CGPoint(x: 0, y: geometry.size.height))
                        
                        for (index, item) in data.enumerated() {
                            let x = CGFloat(index) * stepX
                            let normalizedValue = (item.1 - minValue) / range
                            let y = geometry.size.height * (1 - CGFloat(normalizedValue))
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        let lastX = CGFloat(data.count - 1) * stepX
                        path.addLine(to: CGPoint(x: lastX, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [LavaTheme.primaryButton.opacity(0.4), LavaTheme.primaryButton.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Data points
                    ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                        let stepX = geometry.size.width / CGFloat(max(data.count - 1, 1))
                        let x = CGFloat(index) * stepX
                        let normalizedValue = (item.1 - minValue) / range
                        let y = geometry.size.height * (1 - CGFloat(normalizedValue))
                        
                        Circle()
                            .fill(LavaTheme.accent)
                            .frame(width: 10, height: 10)
                            .position(x: x, y: y)
                            .shadow(color: LavaTheme.accent, radius: 5)
                    }
                }
            }
        }
        .padding(.vertical, LavaTheme.paddingSmall)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var icon: String {
        switch transaction.type {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        case .saving: return "flame.fill"
        }
    }
    
    var color: Color {
        switch transaction.type {
        case .income: return LavaTheme.accent
        case .expense: return LavaTheme.primaryButton
        case .saving: return LavaTheme.highlight
        }
    }
    
    var body: some View {
        HStack(spacing: LavaTheme.paddingMedium) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.note)
                    .font(LavaTheme.bodyFont)
                    .foregroundColor(LavaTheme.text)
                
                Text(formatDate(transaction.date))
                    .font(LavaTheme.smallFont)
                    .foregroundColor(LavaTheme.text.opacity(0.6))
            }
            
            Spacer()
            
            Text(formatCurrency(transaction.amount))
                .font(LavaTheme.bodyFont.weight(.semibold))
                .foregroundColor(color)
        }
        .padding(.vertical, LavaTheme.paddingSmall)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: LavaTheme.paddingLarge) {
            ZStack {
                Circle()
                    .fill(LavaTheme.lavaGlow)
                    .frame(width: 100, height: 100)
                    .blur(radius: 30)
                    .opacity(0.4)
                
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 50))
                    .foregroundColor(LavaTheme.text.opacity(0.6))
            }
            
            VStack(spacing: LavaTheme.paddingSmall) {
                Text("No history yet")
                    .font(LavaTheme.headlineFont)
                    .foregroundColor(LavaTheme.text)
                
                Text("Start tracking your finances\nto see your progress here")
                    .font(LavaTheme.bodyFont)
                    .foregroundColor(LavaTheme.text.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(LavaTheme.paddingXLarge)
    }
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

#Preview {
    HistoryView()
}

