import SwiftUI

// MARK: - Row Components
struct BudgetInfoRow: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(formatNumber(amount))원")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

struct BudgetStatusRow: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(formatNumber(amount))원")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.description)
                        .font(.headline)
                    
                    Text(formatDate(expense.date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(formatNumber(expense.amount))원")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.blue)
            }
            
            // 태그 표시
            if !expense.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(expense.tags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            HStack {
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
// MARK: - Card Components
struct CardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemBackground))
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

struct GradientButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    let color: Color
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                Image(systemName: icon)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(colors: [color, color.opacity(0.8)],
                                     startPoint: .leading,
                                     endPoint: .trailing)
                    )
            )
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}
