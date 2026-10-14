//
//  ExpenseListViewModel.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class ExpenseListViewModel {
    var isShowingAddExpenseSheet: Bool = false
    var isShowingSortOptions: Bool = false
    var expenseToEdit: Expense?
    var sortOption: ExpenseSortOption = .dateNewest
    var errorMessage: String?
    
    // No stored context, no custom init needed — default memberwise init works.
    
    func sortedExpenses(from expenses: [Expense]) -> [Expense] {
        switch sortOption {
        case .dateNewest:      return expenses.sorted { $0.date > $1.date }
        case .dateOldest:      return expenses.sorted { $0.date < $1.date }
        case .amountHighToLow: return expenses.sorted { $0.amount > $1.amount }
        case .amountLowToHigh: return expenses.sorted { $0.amount < $1.amount }
        }
    }
    
    func deleteExpense(context: ModelContext, from expenses: [Expense], at offsets: IndexSet) {
        for index in offsets {
            guard expenses.indices.contains(index) else { continue }
            context.delete(expenses[index])
        }
        do {
            try context.save()
        } catch {
            errorMessage = "Failed to delete expense(s): \(error.localizedDescription)"
        }
    }
    
    func showAddExpenseSheet() {
        isShowingAddExpenseSheet = true
    }
    
    func showSortOptions() {
        isShowingSortOptions = true
    }
    
    func editExpense(_ expense: Expense) {
        expenseToEdit = expense
    }
}
