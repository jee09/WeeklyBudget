
// Views/Main/WeekHistoryView.swift
import SwiftUI

struct WeekHistoryView: View {
    let history: [WeekHistory]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(history.sorted(by: { $0.startDate > $1.startDate })) { week in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(formatDate(week.startDate)) ~ \(formatDate(week.endDate))")
                            .font(.headline)
                        Text("주간 예산: \(formatNumber(week.weekInfo.budget))원")
                        Text("총 지출: \(formatNumber(week.totalSpent))원")
                            .foregroundColor(week.totalSpent > week.weekInfo.budget ? .red : .blue)
                        
                        if !week.expenses.isEmpty {
                            DisclosureGroup("지출 내역") {
                                ForEach(week.expenses.sorted(by: { $0.date > $1.date })) { expense in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(expense.description)
                                            Text(formatDateTime(expense.date))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("\(formatNumber(expense.amount))원")
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("지출 기록")
            .navigationBarItems(trailing: Button("닫기") { dismiss() })
        }
    }
}
#Preview {
    WeekHistoryView(history: [
        WeekHistory(
            weekInfo: WeekInfo(
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!,
                budget: 100000,
                dailyBudget: 14285
            ),
            expenses: [
                Expense(amount: 15000, description: "점심"),
                Expense(amount: 20000, description: "저녁")
            ]
        )
    ])
}
