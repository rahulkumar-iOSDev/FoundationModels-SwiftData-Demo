//
//  SortOptionsSheet.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 26/09/26.
//

import SwiftUI

struct SortOptionsSheet: View {
    @Binding var sortOption: ExpenseSortOption
    @Binding var isPresented: Bool

    private var sheetHeight: CGFloat {
        let rowHeight: CGFloat = 44
        let navBar: CGFloat = 56
        let safeArea: CGFloat = 44
        return CGFloat(ExpenseSortOption.allCases.count) * rowHeight + navBar + safeArea
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(ExpenseSortOption.allCases) { option in
                    HStack {
                        Text(option.rawValue)
                            .foregroundStyle(.primary)
                        Spacer()
                        if sortOption == option {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        sortOption = option
                        isPresented = false
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .scrollDisabled(true)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var sortOption: ExpenseSortOption = .dateNewest
    @Previewable @State var isPresented = true

    return Color.clear
        .sheet(isPresented: $isPresented) {
            SortOptionsSheet(sortOption: $sortOption, isPresented: $isPresented)
        }
}
