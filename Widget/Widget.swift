//
//  Widget.swift
//  Widget
//
//  Created by ict-WONJI on 11/7/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = BudgetEntry
    let groupIdentifier = "group.com.wonji.WeeklyBudget"
    
    func placeholder(in context: Context) -> BudgetEntry {
        BudgetEntry(
            date: Date(),
            remainingBudget: 100000,
            dailyAvailable: 20000,
            todayRemainingBudget: 15000
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BudgetEntry) -> ()) {
        let userDefaults = UserDefaults(suiteName: groupIdentifier)
        
        let remainingBudget = userDefaults?.double(forKey: "remainingBudget") ?? 0
        let dailyAvailable = userDefaults?.double(forKey: "dailyAvailable") ?? 0
        let todayRemainingBudget = userDefaults?.double(forKey: "todayRemainingBudget") ?? 0
        
        print("위젯 - remainingBudget: \(remainingBudget), dailyAvailable: \(dailyAvailable), todayRemaining: \(todayRemainingBudget)")
        
        let entry = BudgetEntry(
            date: Date(),
            remainingBudget: remainingBudget,
            dailyAvailable: dailyAvailable,
            todayRemainingBudget: todayRemainingBudget
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<BudgetEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: groupIdentifier)
        
        let remainingBudget = userDefaults?.double(forKey: "remainingBudget") ?? 0
        let dailyAvailable = userDefaults?.double(forKey: "dailyAvailable") ?? 0
        let todayRemainingBudget = userDefaults?.double(forKey: "todayRemainingBudget") ?? 0
        
        let entry = BudgetEntry(
            date: Date(),
            remainingBudget: remainingBudget,
            dailyAvailable: dailyAvailable,
            todayRemainingBudget: todayRemainingBudget
        )
        
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

struct BudgetEntry: TimelineEntry {
    let date: Date
    let remainingBudget: Double
    let dailyAvailable: Double
    let todayRemainingBudget: Double
}

struct BudgetWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            // 배경을 더 진한 색상으로 변경
            Color(.systemBackground)
            
            VStack(spacing: 8) {
                // 남은 예산 섹션
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "banknote.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14))
                        Text("남은 예산")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Text("\(formatNumber(entry.remainingBudget))원")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 2)
                
                // 구분선
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 8)
                
                // 하루 사용 가능 금액 섹션
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.green)
                            .font(.system(size: 14))
                        Text("하루 사용 가능")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Text("\(formatNumber(entry.dailyAvailable))원")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                
                // 구분선
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 8)
                
                // 오늘 남은 예산 섹션
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .foregroundStyle(entry.todayRemainingBudget >= 0 ? .green : .red)
                            .font(.system(size: 14))
                        Text("오늘 남은 예산")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                    }
                    
                    Text("\(formatNumber(entry.todayRemainingBudget))원")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(entry.todayRemainingBudget >= 0 ? .green : .red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(12)
        }
        .containerBackground(.background, for: .widget)
    }
    
    private func formatNumber(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
}

@main
struct WidgetExtension: Widget {
    let kind: String = "com.wonji.WeeklyBudget.Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BudgetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("예산 관리")
        .description("이번 주 남은 예산과 오늘 사용 가능 금액을 확인하세요.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)  // 틴트 효과 비활성화
    }
}
