//
//  DataModels.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import Foundation

struct SavingGoal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var createdDate: Date
    var isCompleted: Bool {
        currentAmount >= targetAmount
    }
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    var motivationalMessage: String {
        let progressPercent = progress * 100
        if progressPercent >= 100 {
            return "Goal Achieved! 🎉"
        } else if progressPercent >= 75 {
            return "Almost there!"
        } else if progressPercent >= 50 {
            return "Keep going!"
        } else if progressPercent >= 25 {
            return "Making progress!"
        } else {
            return "You've got this!"
        }
    }
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var type: TransactionType
    var date: Date
    var note: String
}

enum TransactionType: String, Codable {
    case income
    case expense
    case saving
}

struct DailyBalance: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var income: Double
    var expenses: Double
    var savings: Double
    var balance: Double {
        income - expenses
    }
}

struct AppStatistics: Codable {
    var totalSaved: Double
    var goalsAchieved: Int
    var currentStreak: Int
    var lastActivityDate: Date
}

