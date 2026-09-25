//
//  ContentView.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 23/09/26.
//
import SwiftUI
import SwiftData

// MARK: - Expense List View

struct ExpenseListView: View {
    @Environment(\.modelContext) private var context
    @State private var isShowingAddExpenseSheet: Bool = false
    @Query var expenses: [Expense] = []
    @State private var expenseToEdit: Expense?
    
    @State private var sortOption: ExpenseSortOption = .dateNewest
    @State private var isShowingSortOptions: Bool = false
    
    private var sortedExpenses: [Expense] {
        switch sortOption {
        case .dateNewest:       return expenses.sorted { $0.date > $1.date }
        case .dateOldest:       return expenses.sorted { $0.date < $1.date }
        case .amountHighToLow:  return expenses.sorted { $0.amount > $1.amount }
        case .amountLowToHigh:  return expenses.sorted { $0.amount < $1.amount }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if expenses.isEmpty {
                    EmptyListView(isShowingAddExpenseSheet: $isShowingAddExpenseSheet)
                        .offset(y: -60)
                } else {
                    List {
                        ForEach(sortedExpenses) { expense in
                            ExpenseCell(expense: expense)
                                .onTapGesture {
                                    expenseToEdit = expense
                                }
                        }
                        .onDelete { indexSet in
                            deleteExpense(at: indexSet)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddExpenseSheet) {
                AddExpenseView()
            }
            .sheet(item: $expenseToEdit) { expense in
                UpdateExpenseView(expense: expense)
            }
            .sortOptionsSheet(
                isPresented: $isShowingSortOptions,
                sortOption: $sortOption
            )
            .toolbar {
                if !expenses.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if expenses.count >= 2 {
                            Button {
                                isShowingSortOptions = true
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                        Button {
                            isShowingAddExpenseSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
        }
    }
    
    private func deleteExpense(at offsets: IndexSet) {
        for index in offsets {
            guard sortedExpenses.indices.contains(index) else { continue }
            context.delete(sortedExpenses[index])
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete expense(s): \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview

#Preview {
    ExpenseListView()
}

// MARK: - Empty State View

struct EmptyListView: View {
    @Binding var isShowingAddExpenseSheet: Bool
    var body: some View {
        ContentUnavailableView {
            Label("No Expenses", systemImage: "list.bullet.rectangle.portrait")
        } description: {
            Text("Start adding expense to see your list.")
                .font(.callout)
        } actions: {
            Button {
                isShowingAddExpenseSheet = true
            } label: {
                Text("Add Expense")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(2)
            }
            .buttonStyle(.glassProminent)
        }
    }
}

// MARK: - Expense Cell

struct ExpenseCell: View {
    let expense: Expense

    private var tint: Color {
        Color(hex: expense.expenseTintHex ?? "007AFF")
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: expense.expenseSymbol ?? "creditcard.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(
                    Circle().fill(tint.gradient)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(expense.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(expense.date.toString(format: .dd_MMM_yyyy))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(expense.amount.currencyString())
                .font(.body.weight(.semibold))
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sort Options Sheet

private struct SortOptionsSheet: View {
    @Binding var sortOption: ExpenseSortOption
    @Binding var isPresented: Bool
    
    /// Content-driven height — snug fit, no empty space, no scrolling.
    private var sheetHeight: CGFloat {
        let rowHeight: CGFloat = 44     // one List row
        let navBar: CGFloat = 56        // inline nav bar + Done button
        let safeArea: CGFloat = 34      // home indicator area
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

// MARK: - View Modifier

private struct SortOptionsSheetModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var sortOption: ExpenseSortOption
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SortOptionsSheet(
                    sortOption: $sortOption,
                    isPresented: $isPresented
                )
            }
    }
}

// MARK: - View Extension

extension View {
    /// Presents the expense sort options sheet.
    func sortOptionsSheet(
        isPresented: Binding<Bool>,
        sortOption: Binding<ExpenseSortOption>
    ) -> some View {
        modifier(
            SortOptionsSheetModifier(
                isPresented: isPresented,
                sortOption: sortOption
            )
        )
    }
}
