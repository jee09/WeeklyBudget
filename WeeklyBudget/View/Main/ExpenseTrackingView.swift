import SwiftUI
import WidgetKit

struct ExpenseTrackingView: View {
    let weekInfo: WeekInfo
    @State private var expenses: [Expense] = []
    @State private var newExpense: String = ""
    @State private var expenseDescription: String = ""
    @State private var shouldNavigateToRoot = false
    @State private var showHistory = false
    @State private var weekHistory: [WeekHistory] = []
    @State private var showAddExpense = false
    @State private var expenseToEdit: Expense?
    @State private var isEditMode = false
    
    private var remainingDays: Int {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘부터 마지막 날까지의 일수를 계산 (양 끝 날짜 모두 포함)
        let daysUntilEnd = calendar.dateComponents([.day],
            from: calendar.startOfDay(for: today),
            to: calendar.startOfDay(for: weekInfo.endDate)).day ?? 0
        return max(1, daysUntilEnd + 1)
    }
    
    private func saveExpenses() {
        UserDefaults.saveExpenses(expenses)
        UserDefaults.updateWidget(remainingBudget: remainingBudget,
                                dailyAvailable: weekInfo.dailyBudget,
                                todayRemainingBudget: todayRemainingBudget)
    }
    
    var totalSpent: Double { expenses.reduce(0) { $0 + $1.amount } }
    var remainingBudget: Double { weekInfo.budget - totalSpent }
    
    // 오늘 사용한 금액 계산
    private var todaySpent: Double {
        let calendar = Calendar.current
        let today = Date()
        return expenses
            .filter { calendar.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    // 오늘 남은 사용 가능 금액 계산
    var todayRemainingBudget: Double {
        weekInfo.dailyBudget - todaySpent
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6)],
                             startPoint: .top,
                             endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 이번 주 기간 카드
                        VStack(spacing: 10) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text("\(formatDate(weekInfo.startDate)) ~ \(formatDate(weekInfo.endDate))")
                                    .font(.headline)
                            }
                            Text("남은 일수: \(remainingDays)일")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(CardBackground())
                        
                        // 예산 현황 카드
                        VStack(spacing: 15) {
                            BudgetStatusRow(title: "남은 예산",
                                          amount: remainingBudget,
                                          color: .blue,
                                          icon: "banknote")
                            
                            Divider()
                            
                            BudgetStatusRow(title: "총 지출",
                                          amount: totalSpent,
                                          color: .orange,
                                          icon: "cart.fill")
                            
                            Divider()
                            
                            BudgetStatusRow(title: "하루 사용 가능",
                                          amount: weekInfo.dailyBudget,
                                          color: .green,
                                          icon: "dollarsign.circle.fill")
                            
                            Divider()
                            
                            BudgetStatusRow(title: "오늘 남은 예산",
                                          amount: todayRemainingBudget,
                                          color: todayRemainingBudget >= 0 ? .green : .red,
                                          icon: "creditcard.fill")
                        }
                        .padding()
                        .background(CardBackground())
                        
                        // 지출 내역 섹션
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Label("지출 내역", systemImage: "list.bullet")
                                    .font(.headline)
                                Spacer()
                                Button(action: { showAddExpense = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                            .padding()
                            
                            if expenses.isEmpty {
                                Text("아직 지출 내역이 없습니다")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                ForEach(expenses.sorted(by: { $0.date > $1.date })) { expense in
                                    ExpenseRow(expense: expense,
                                        onEdit: {
                                            expenseToEdit = expense
                                            isEditMode = true
                                        },
                                        onDelete: {
                                            if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                                                expenses.remove(at: index)
                                                saveExpenses()
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .background(CardBackground())
                        
                        // 액션 버튼들
                        HStack(spacing: 15) {
                            Button(action: {
                                weekHistory = UserDefaults.loadWeekHistory()
                                showHistory = true
                            }) {
                                Label("이전 기록", systemImage: "clock.arrow.circlepath")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.2), radius: 3)
                            }
                            
                            Button(action: resetExpenses) {
                                Label("초기화", systemImage: "arrow.counterclockwise")
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.2), radius: 3)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("지출 관리")
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $shouldNavigateToRoot) {
                BudgetSetupView()
            }
            .sheet(isPresented: $showHistory) {
                WeekHistoryView(history: weekHistory)
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(
                    newExpense: $newExpense,
                    expenseDescription: $expenseDescription,
                    onAdd: {
                        addExpense()
                        showAddExpense = false
                    }
                )
                .presentationDetents([.height(300)])
            }
            .sheet(isPresented: $isEditMode) {
                if let expense = expenseToEdit {
                    EditExpenseSheet(
                        expense: expense,
                        onUpdate: { updatedExpense in
                            updateExpense(updatedExpense)
                            isEditMode = false
                        }
                    )
                    .presentationDetents([.height(300)])
                }
            }
            .onAppear {
                checkAndResetIfNeeded()
                expenses = UserDefaults.loadExpenses()
            }
        }
    }
    
    // MARK: - Helper Methods
    private func updateExpense(_ updatedExpense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
            expenses[index] = updatedExpense
            saveExpenses()
        }
    }
    
    private func checkAndResetIfNeeded() {
        if !weekInfo.isCurrentWeek() {
            saveToHistory()
            resetExpenses()
        }
    }
    
    private func addExpense() {
        guard let amount = Double(newExpense), amount > 0 else { return }
        
        let expense = Expense(
            amount: amount,
            description: expenseDescription,  // 빈 문자열 허용
            date: Date()
        )
        expenses.append(expense)
        saveExpenses()
        
        newExpense = ""
        expenseDescription = ""
    }
    
    private func saveToHistory() {
        let newHistory = WeekHistory(weekInfo: weekInfo, expenses: expenses)
        var savedHistory = UserDefaults.loadWeekHistory()
        savedHistory.append(newHistory)
        UserDefaults.saveWeekHistory(savedHistory)
    }
    
    private func resetExpenses() {
        UserDefaults.shared.removeObject(forKey: "expenses")
        UserDefaults.shared.removeObject(forKey: "currentWeekInfo")
        UserDefaults.updateWidget(
            remainingBudget: 0,
            dailyAvailable: 0,
            todayRemainingBudget: 0
        )
        shouldNavigateToRoot = true
    }
}

#Preview {
    NavigationStack {
        ExpenseTrackingView(weekInfo: WeekInfo(
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 6, to: Date())!,
            budget: 100000,
            dailyBudget: 14285
        ))
    }
}
