//
//  DataManager.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var goals: [SavingGoal] = []
    @Published var transactions: [Transaction] = []
    @Published var dailyBalances: [DailyBalance] = []
    @Published var totalSavings: Double = 0
    @Published var monthlyIncome: Double = 0
    @Published var monthlyExpenses: Double = 0
    @Published var statistics: AppStatistics
    @Published var hasCompletedOnboarding: Bool = false
    
    private let goalsKey = "savingGoals"
    private let transactionsKey = "transactions"
    private let dailyBalancesKey = "dailyBalances"
    private let totalSavingsKey = "totalSavings"
    private let statisticsKey = "statistics"
    private let onboardingKey = "hasCompletedOnboarding"
    
    private init() {
        self.statistics = AppStatistics(
            totalSaved: 0,
            goalsAchieved: 0,
            currentStreak: 0,
            lastActivityDate: Date()
        )
        loadData()
        calculateMonthlyData()
    }
    
    // MARK: - Data Persistence
    
    func loadData() {
        if let goalsData = UserDefaults.standard.data(forKey: goalsKey),
           let decodedGoals = try? JSONDecoder().decode([SavingGoal].self, from: goalsData) {
            goals = decodedGoals
        }
        
        if let transactionsData = UserDefaults.standard.data(forKey: transactionsKey),
           let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: transactionsData) {
            transactions = decodedTransactions
        }
        
        if let balancesData = UserDefaults.standard.data(forKey: dailyBalancesKey),
           let decodedBalances = try? JSONDecoder().decode([DailyBalance].self, from: balancesData) {
            dailyBalances = decodedBalances
        }
        
        totalSavings = UserDefaults.standard.double(forKey: totalSavingsKey)
        
        if let statsData = UserDefaults.standard.data(forKey: statisticsKey),
           let decodedStats = try? JSONDecoder().decode(AppStatistics.self, from: statsData) {
            statistics = decodedStats
        }
        
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func saveData() {
        if let goalsData = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(goalsData, forKey: goalsKey)
        }
        
        if let transactionsData = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(transactionsData, forKey: transactionsKey)
        }
        
        if let balancesData = try? JSONEncoder().encode(dailyBalances) {
            UserDefaults.standard.set(balancesData, forKey: dailyBalancesKey)
        }
        
        UserDefaults.standard.set(totalSavings, forKey: totalSavingsKey)
        
        if let statsData = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(statsData, forKey: statisticsKey)
        }
        
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingKey)
    }
    
    // MARK: - Goal Management
    
    func addGoal(title: String, targetAmount: Double) {
        let newGoal = SavingGoal(
            title: title,
            targetAmount: targetAmount,
            currentAmount: 0,
            createdDate: Date()
        )
        goals.append(newGoal)
        saveData()
    }
    
    func updateGoalProgress(goalId: UUID, amount: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            let wasCompleted = goals[index].isCompleted
            goals[index].currentAmount += amount
            
            if !wasCompleted && goals[index].isCompleted {
                statistics.goalsAchieved += 1
            }
            
            totalSavings += amount
            statistics.totalSaved = totalSavings
            addTransaction(amount: amount, type: .saving, note: "Saved for \(goals[index].title)")
            updateStreak()
            saveData()
        }
    }
    
    func deleteGoal(goalId: UUID) {
        goals.removeAll { $0.id == goalId }
        saveData()
    }
    
    // MARK: - Transaction Management
    
    func addTransaction(amount: Double, type: TransactionType, note: String) {
        let transaction = Transaction(
            amount: amount,
            type: type,
            date: Date(),
            note: note
        )
        transactions.append(transaction)
        
        updateDailyBalance(transaction: transaction)
        calculateMonthlyData()
        saveData()
    }
    
    private func updateDailyBalance(transaction: Transaction) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let index = dailyBalances.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            switch transaction.type {
            case .income:
                dailyBalances[index].income += transaction.amount
            case .expense:
                dailyBalances[index].expenses += transaction.amount
            case .saving:
                dailyBalances[index].savings += transaction.amount
            }
        } else {
            var newBalance = DailyBalance(
                date: today,
                income: 0,
                expenses: 0,
                savings: 0
            )
            
            switch transaction.type {
            case .income:
                newBalance.income = transaction.amount
            case .expense:
                newBalance.expenses = transaction.amount
            case .saving:
                newBalance.savings = transaction.amount
            }
            
            dailyBalances.append(newBalance)
        }
        
        // Keep only last 30 days
        dailyBalances.sort { $0.date > $1.date }
        if dailyBalances.count > 30 {
            dailyBalances = Array(dailyBalances.prefix(30))
        }
    }
    
    func calculateMonthlyData() {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        let monthTransactions = transactions.filter { transaction in
            let month = calendar.component(.month, from: transaction.date)
            let year = calendar.component(.year, from: transaction.date)
            return month == currentMonth && year == currentYear
        }
        
        monthlyIncome = monthTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        monthlyExpenses = monthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActivity = calendar.startOfDay(for: statistics.lastActivityDate)
        
        let daysDifference = calendar.dateComponents([.day], from: lastActivity, to: today).day ?? 0
        
        if daysDifference == 0 {
            // Same day, keep streak
        } else if daysDifference == 1 {
            // Next day, increment streak
            statistics.currentStreak += 1
        } else {
            // Streak broken
            statistics.currentStreak = 1
        }
        
        statistics.lastActivityDate = Date()
        statistics.totalSaved = totalSavings
    }
    
    // MARK: - Data Management
    
    func resetAllData() {
        goals = []
        transactions = []
        dailyBalances = []
        totalSavings = 0
        monthlyIncome = 0
        monthlyExpenses = 0
        statistics = AppStatistics(
            totalSaved: 0,
            goalsAchieved: 0,
            currentStreak: 0,
            lastActivityDate: Date()
        )
        saveData()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func getRecentTransactions(limit: Int = 10) -> [Transaction] {
        return Array(transactions.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    func getChartData() -> [DailyBalance] {
        return dailyBalances.sorted { $0.date < $1.date }
    }
}

