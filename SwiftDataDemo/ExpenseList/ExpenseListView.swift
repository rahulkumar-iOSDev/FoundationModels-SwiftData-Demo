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
    @State private var viewModel = ExpenseListViewModel()
    @Query var expenses: [Expense] = []

    private var sortedExpenses: [Expense] {
        viewModel.sortedExpenses(from: expenses)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if expenses.isEmpty {
                    EmptyListView(isShowingAddExpenseSheet: $viewModel.isShowingAddExpenseSheet)
                        .offset(y: -60)
                } else {
                    List {
                        ForEach(sortedExpenses) { expense in
                            ExpenseCell(expense: expense)
                                .onTapGesture {
                                    viewModel.editExpense(expense)
                                }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteExpense(context: context, from: sortedExpenses, at: indexSet)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddExpenseSheet) {
                AddExpenseView()
            }
            .sheet(item: $viewModel.expenseToEdit) { expense in
                UpdateExpenseView(expense: expense)
            }
            .sortOptionsSheet(
                isPresented: $viewModel.isShowingSortOptions,
                sortOption: $viewModel.sortOption
            )
            .toolbar {
                if !expenses.isEmpty {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        if expenses.count >= 2 {
                            Button {
                                viewModel.showSortOptions()
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                        Button {
                            viewModel.showAddExpenseSheet()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .alert(
                "Couldn't Delete",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                presenting: viewModel.errorMessage
            ) { _ in
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: { message in
                Text(message)
            }
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

    private var sheetHeight: CGFloat {
        let rowHeight: CGFloat = 44
        let navBar: CGFloat = 56
        let safeArea: CGFloat = 34
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
