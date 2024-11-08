// Models.swift
import Foundation

struct WeekInfo: Codable {
    var startDate: Date
    var endDate: Date
    var budget: Double
    var dailyBudget: Double
    
    func isCurrentWeek() -> Bool {
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2
        let currentWeekStart = calendar.date(from: components)!
        return calendar.isDate(startDate, equalTo: currentWeekStart, toGranularity: .day)
    }
}

struct Expense: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let description: String
    let date: Date
    let tags: [ExpenseTag]
    
    init(id: UUID = UUID(), amount: Double, description: String = "", date: Date = Date(), tags: [ExpenseTag] = []) {
        self.id = id
        self.amount = amount
        self.description = description
        self.date = date
        self.tags = tags
    }
}

struct WeekHistory: Codable, Identifiable {
    let id: UUID
    let weekInfo: WeekInfo
    let expenses: [Expense]
    let totalSpent: Double
    let startDate: Date
    let endDate: Date
    
    init(weekInfo: WeekInfo, expenses: [Expense]) {
        self.id = UUID()
        self.weekInfo = weekInfo
        self.expenses = expenses
        self.totalSpent = expenses.reduce(0) { $0 + $1.amount }
        self.startDate = weekInfo.startDate
        self.endDate = weekInfo.endDate
    }
}
struct ExpenseTag: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
