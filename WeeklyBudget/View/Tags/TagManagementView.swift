//
//  TagManagementView.swift
//  WeeklyBudget
//
//  Created by ict-WONJI on 11/8/24.
//


import SwiftUI

struct TagManagementView: View {
    @Binding var tags: [ExpenseTag]
    @State private var newTagName: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        TextField("새로운 태그", text: $newTagName)
                        Button(action: addTag) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newTagName.isEmpty)
                    }
                } header: {
                    Text("태그 추가")
                }
                
                Section {
                    ForEach(tags) { tag in
                        Text(tag.name)
                    }
                    .onDelete(perform: deleteTags)
                } header: {
                    Text("저장된 태그")
                }
            }
            .navigationTitle("태그 관리")
            .navigationBarItems(
                trailing: Button("완료") { dismiss() }
            )
        }
    }
    
    private func addTag() {
        let newTag = ExpenseTag(name: newTagName)
        tags.append(newTag)
        UserDefaults.saveTags(tags)
        newTagName = ""
    }
    
    private func deleteTags(at offsets: IndexSet) {
        tags.remove(atOffsets: offsets)
        UserDefaults.saveTags(tags)
    }
}

