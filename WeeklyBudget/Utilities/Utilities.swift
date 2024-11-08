import SwiftUI
import WidgetKit

// MARK: - Formatting Extensions
extension View {
    func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    static let groupIdentifier = "group.com.wonji.WeeklyBudget"
    static let shared = UserDefaults(suiteName: groupIdentifier)!
    
    static func saveExpenses(_ expenses: [Expense]) {
        if let encoded = try? JSONEncoder().encode(expenses) {
            shared.set(encoded, forKey: "expenses")
            
            if let data = shared.data(forKey: "currentWeekInfo"),
               let weekInfo = try? JSONDecoder().decode(WeekInfo.self, from: data) {
                
                let totalSpent = expenses.reduce(0) { $0 + $1.amount }
                let remainingBudget = weekInfo.budget - totalSpent
                
                // dailyAvailable은 weekInfo에 저장된 초기값 사용
                let dailyAvailable = weekInfo.dailyBudget
                
                // 오늘 사용한 금액 계산
                let calendar = Calendar.current
                let today = Date()
                let todaySpent = expenses
                    .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
                    .reduce(0) { $0 + $1.amount }
                
                // 오늘 남은 예산 계산 (고정된 일일 예산에서 오늘 사용한 금액 차감)
                let todayRemainingBudget = dailyAvailable - todaySpent
                
                updateWidget(
                    remainingBudget: remainingBudget,
                    dailyAvailable: dailyAvailable,
                    todayRemainingBudget: todayRemainingBudget
                )
            }
        }
    }
    
    static func loadExpenses() -> [Expense] {
        if let data = shared.data(forKey: "expenses"),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            return decoded
        }
        return []
    }
    
    static func saveWeekHistory(_ history: [WeekHistory]) {
        if let encoded = try? JSONEncoder().encode(history) {
            shared.set(encoded, forKey: "weekHistory")
        }
    }
    
    static func loadWeekHistory() -> [WeekHistory] {
        if let data = shared.data(forKey: "weekHistory"),
           let decoded = try? JSONDecoder().decode([WeekHistory].self, from: data) {
            return decoded
        }
        return []
    }
    
    static func saveTags(_ tags: [ExpenseTag]) {
         if let encoded = try? JSONEncoder().encode(tags) {
             shared.set(encoded, forKey: "expenseTags")
         }
     }
     
     static func loadTags() -> [ExpenseTag] {
         if let data = shared.data(forKey: "expenseTags"),
            let decoded = try? JSONDecoder().decode([ExpenseTag].self, from: data) {
             return decoded
         }
         return []
     }
    
    static func updateWidget(remainingBudget: Double, dailyAvailable: Double, todayRemainingBudget: Double) {
        shared.set(remainingBudget, forKey: "remainingBudget")
        shared.set(dailyAvailable, forKey: "dailyAvailable")
        shared.set(todayRemainingBudget, forKey: "todayRemainingBudget")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
