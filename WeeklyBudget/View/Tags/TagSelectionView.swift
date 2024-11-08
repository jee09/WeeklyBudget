//
//  TagSelectionView.swift
//  WeeklyBudget
//
//  Created by ict-WONJI on 11/8/24.
//

import SwiftUI

struct TagSelectionView: View {
    @Binding var selectedTags: Set<ExpenseTag>
    let availableTags: [ExpenseTag]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableTags) { tag in
                    TagButton(
                        title: tag.name,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
