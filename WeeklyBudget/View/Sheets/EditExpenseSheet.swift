import SwiftUI


struct EditExpenseSheet: View {
    let expense: Expense
    let onUpdate: (Expense) -> Void
    
    @State private var amount: String
    @State private var description: String
    @Environment(\.dismiss) var dismiss
    
    init(expense: Expense, onUpdate: @escaping (Expense) -> Void) {
        self.expense = expense
        self.onUpdate = onUpdate
        _amount = State(initialValue: String(format: "%.0f", expense.amount))
        _description = State(initialValue: expense.description)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                                   .frame(height: 30)
                TextField("금액", text: $amount)
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
                
                TextField("내용", text: $description)
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
                
                Button(action: updateExpense) {
                    Text("수정하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange)
                        )
                }
                .disabled(amount.isEmpty || description.isEmpty)
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("지출 수정")
            .navigationBarItems(trailing: Button("취소") { dismiss() })
        }
    }
    
    private func updateExpense() {
        guard let amountDouble = Double(amount), amountDouble > 0 else { return }
        
        let updatedExpense = Expense(
            id: expense.id,
            amount: amountDouble,
            description: description,
            date: expense.date
        )
        
        onUpdate(updatedExpense)
        dismiss()
    }
}
