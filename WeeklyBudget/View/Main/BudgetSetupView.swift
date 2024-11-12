// Views/Main/BudgetSetupView.swift
import SwiftUI
// MARK: - BudgetSetupView
struct BudgetSetupView: View {
    // MARK: - Properties
    @State private var weeklyBudget: String = ""
    @State private var weekInfo: WeekInfo?
    @State private var shouldNavigate = false
    
    // MARK: - Computed Properties
    private var currentWeekDates: (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        // 이번 주 월요일 오전 7시
        var startComponents = calendar.dateComponents([.year, .month, .weekOfYear], from: today)
        startComponents.weekday = 2  // 월요일
        startComponents.hour = 7     // 오전 7시
        startComponents.minute = 0
        startComponents.second = 0
        let startDate = calendar.date(from: startComponents)!
        
        // 일요일 오전 6:59:59 (정확히 7일)
        var endComponents = calendar.dateComponents([.year, .month, .weekOfYear], from: today)
        endComponents.weekday = 1  // 일요일 (1이 일요일입니다)
        endComponents.hour = 6     // 오전 6시
        endComponents.minute = 59  // 59분
        endComponents.second = 59  // 59초
        var endDate = calendar.date(from: endComponents)!
        endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: endDate)!
        
        print("시작일: \(formatDateTime(startDate))")
        print("종료일: \(formatDateTime(endDate))")
        
        return (startDate, endDate)
    }
    
    // 날짜 출력을 위한 헬퍼 함수
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // MARK: - Helper Methods
    private func setupWeekInfo(budget: Double) -> WeekInfo {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘부터 일요일 06:59:59까지의 남은 일수 계산
        let daysUntilEnd = calendar.dateComponents([.day],
            from: calendar.startOfDay(for: today),
            to: calendar.startOfDay(for: currentWeekDates.end)).day ?? 0
        let remainingDays = max(1, daysUntilEnd + 1)
        
        // 남은 일수로 나눠서 일일 예산 계산
        let dailyBudget = floor(budget / Double(remainingDays))
        
        let weekInfo = WeekInfo(
            startDate: currentWeekDates.start,
            endDate: currentWeekDates.end,
            budget: budget,
            dailyBudget: dailyBudget
        )
        
        UserDefaults.saveWeekInfo(weekInfo)
        UserDefaults.updateWidget(
            remainingBudget: budget,
            dailyAvailable: dailyBudget,
            todayRemainingBudget: dailyBudget
        )
        
        return weekInfo
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: Background
                LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6)],
                             startPoint: .top,
                             endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // MARK: Weekly Info Card
                        weeklyInfoCard
                        
                        // MARK: Budget Input Card
                        budgetInputCard
                        
                        // MARK: Budget Info Card
                        if let budget = Double(weeklyBudget), budget > 0 {
                            budgetInfoCard(budget: budget)
                            
                            // MARK: Start Button
                            startButton(budget: budget)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("예산 설정")
            .navigationDestination(isPresented: $shouldNavigate) {
                if let weekInfo = weekInfo {
                    ExpenseTrackingView(weekInfo: weekInfo)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .onAppear {
                    // 이미 설정된 WeekInfo가 있고 현재 주차의 것이라면 ExpenseTrackingView로 이동
                    if let savedWeekInfo = UserDefaults.loadWeekInfo(),
                       savedWeekInfo.isCurrentWeek() {
                        weekInfo = savedWeekInfo
                        shouldNavigate = true
                    }
                }
    }
    
    // MARK: - View Components
    private var weeklyInfoCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("이번 주 기간", systemImage: "calendar")
                .font(.headline)
                .foregroundColor(.primary)
            
            // endDate에서 1초를 빼서 표시 (월 07:00 ~ 일 06:59)
            let displayEndDate = Calendar.current.date(byAdding: .second, value: -1, to: currentWeekDates.end)!
            
            Text("\(formatDate(currentWeekDates.start)) ~ \(formatDate(displayEndDate))")
                .font(.title3)
                .foregroundColor(.blue)
                
            // 남은 일수 계산 및 표시
            let calendar = Calendar.current
            let today = Date()
            let daysUntilEnd = calendar.dateComponents([.day],
                from: calendar.startOfDay(for: today),
                to: calendar.startOfDay(for: currentWeekDates.end)).day ?? 0
            let remainingDays = max(1, daysUntilEnd + 1)
            
            Text("이번 주 남은 일수: \(remainingDays)일")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(CardBackground())
    }
    
    private var budgetInputCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("주간 예산 설정", systemImage: "dollarsign.circle.fill")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("예산을 입력해주세요", text: $weeklyBudget)
                .keyboardType(.numberPad)
                .font(.system(.body, design: .rounded))
                .padding()
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(CardBackground())
    }
    
    private func budgetInfoCard(budget: Double) -> some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.blue)
                Text("예산 정보")
                    .font(.headline)
            }
            
            VStack(spacing: 10) {
                BudgetInfoRow(title: "이번 주 예산",
                             amount: budget,
                             color: .blue)
                
                // 남은 일수로 나눈 일일 예산 표시
                let calendar = Calendar.current
                let today = Date()
                let daysUntilEnd = calendar.dateComponents([.day],
                    from: calendar.startOfDay(for: today),
                    to: calendar.startOfDay(for: currentWeekDates.end)).day ?? 0
                let remainingDays = max(1, daysUntilEnd + 1)
                
                let dailyBudget = floor(budget / Double(remainingDays))
                BudgetInfoRow(title: "하루 사용 가능",
                             amount: dailyBudget,
                             color: .green)
            }
        }
        .padding()
        .background(CardBackground())
    }
    
    private func startButton(budget: Double) -> some View {
        NavigationLink {
            ExpenseTrackingView(weekInfo: setupWeekInfo(budget: budget))
                .navigationBarBackButtonHidden(true)
        } label: {
            HStack {
                Text("시작하기")
                    .font(.headline)
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(colors: [.blue, .blue.opacity(0.8)],
                                     startPoint: .leading,
                                     endPoint: .trailing)
                    )
            )
            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
        }
        .padding(.top)
    }
    
    // MARK: - Helper Functions
    private func checkSavedWeekInfo() {
        if let savedWeekInfo = UserDefaults.loadWeekInfo(),
           savedWeekInfo.isCurrentWeek() {
            weekInfo = savedWeekInfo
            shouldNavigate = true
        }
    }
}
