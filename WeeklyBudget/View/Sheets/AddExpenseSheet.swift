// Views/Sheets/AddExpenseSheet.swift
import SwiftUI

struct AddExpenseSheet: View {
    @Binding var newExpense: String
    @Binding var expenseDescription: String
    let onAdd: () -> Void
    
    @State private var tags: [ExpenseTag] = []
    @State private var selectedTags: Set<ExpenseTag> = []
    @State private var showTagManagement = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("금액")) {
                    TextField("금액을 입력하세요", text: $newExpense)
                        .keyboardType(.numberPad)
                }
                
               
                
//                Section(header: HStack {
//                    Text("태그")
//                    Spacer()
//                    Button(action: { showTagManagement = true }) {
//                        Image(systemName: "plus.circle")
//                            .foregroundColor(.blue)
//                    }
//                }) {
//                    TagSelectionView(
//                        selectedTags: $selectedTags,
//                        availableTags: tags
//                    )
//                    .padding(.vertical, 8)
//                }
                
                Section(header: Text("설명")) {
                    TextField("설명을 입력하세요", text: $expenseDescription)
                }
            }
            .navigationTitle("지출 추가")
            .navigationBarItems(
                leading: Button("취소") {
                    
                },
                trailing: Button("추가") {
                    onAdd()
                }
                    .disabled(newExpense.isEmpty) 
            )
        }
        .sheet(isPresented: $showTagManagement) {
            TagManagementView(tags: $tags)
        }
        .onAppear {
            tags = UserDefaults.loadTags()
        }
    }
}
