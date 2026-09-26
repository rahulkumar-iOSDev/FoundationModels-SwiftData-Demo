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
            .sheet(isPresented: $viewModel.isShowingSortOptions) {
                SortOptionsSheet(
                    sortOption: $viewModel.sortOption,
                    isPresented: $viewModel.isShowingSortOptions
                )
            }
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
