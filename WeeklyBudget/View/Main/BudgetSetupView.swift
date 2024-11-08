// Views/Main/BudgetSetupView.swift
import SwiftUI

struct BudgetSetupView: View {
    @State private var weeklyBudget: String = ""
    @State private var weekInfo: WeekInfo?
    @State private var shouldNavigate = false
    
    private var currentWeekDates: (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2
        let monday = calendar.date(from: components)!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        return (monday, sunday)
    }
    
    private func setupWeekInfo(budget: Double) -> WeekInfo {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘부터 마지막 날까지의 일수를 계산 (양 끝 날짜 모두 포함)
        let daysUntilEnd = calendar.dateComponents([.day],
            from: calendar.startOfDay(for: today),
            to: calendar.startOfDay(for: currentWeekDates.end)).day ?? 0
        let remainingDays = max(1, daysUntilEnd + 1)
        
        let dailyBudget = floor(budget / Double(remainingDays))
        let weekInfo = WeekInfo(
            startDate: currentWeekDates.start,
            endDate: currentWeekDates.end,
            budget: budget,
            dailyBudget: dailyBudget
        )
        
        // 위젯 데이터 업데이트
        UserDefaults.updateWidget(
            remainingBudget: budget,
            dailyAvailable: dailyBudget,
            todayRemainingBudget: dailyBudget
        )
        
        return weekInfo
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6)],
                             startPoint: .top,
                             endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 주간 정보 카드
                        VStack(alignment: .leading, spacing: 15) {
                            Label("이번 주 기간", systemImage: "calendar")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(formatDate(currentWeekDates.start)) ~ \(formatDate(currentWeekDates.end))")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(CardBackground())
                        
                        // 예산 입력 카드
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
                        
                        // 계산된 예산 정보 카드
                        if let budget = Double(weeklyBudget), budget > 0 {
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
                                    
                                    // 남은 일수 계산
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
                            
                            // 시작 버튼
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
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("예산 설정")
        }
    }
}

#Preview {
    BudgetSetupView()
}
