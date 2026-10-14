//
//  AddExpenseViewModel.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class AddExpenseViewModel {
    // MARK: - Form State
    var expenseName: String = ""
    var date: Date = .now
    var amount: String = ""
    
    // MARK: - Classification State
    var detectedCategory: ExpenseCategory?
    var isClassifying: Bool = false
    
    private var currentClassificationID: UUID?
    
    // MARK: - Validation State
    var errorMessage: String?
    
    private let validator: ExpenseValidation
    
    init(validator: ExpenseValidation = ExpenseValidation()) {
        self.validator = validator
    }
    
    // MARK: - Display Helpers
    
    var isNameEmpty: Bool {
        expenseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var displayCategory: ExpenseCategory? {
        isNameEmpty ? nil : detectedCategory
    }
    
    var isSaveDisabled: Bool {
        amount.isEmpty || expenseName.isEmpty
    }
    
    // MARK: - Classification
    
    func classify(_ name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            currentClassificationID = nil
            detectedCategory = nil
            isClassifying = false
            return
        }
        
        let requestID = UUID()
        currentClassificationID = requestID
        isClassifying = true
        
        // ExpenseClassifier already debounces internally before doing real work.
        let category = await ExpenseClassifier.shared.classify(trimmed)
        
        // A newer request has started since this one began — discard this result entirely.
        guard requestID == currentClassificationID else { return }
        
        detectedCategory = category
        isClassifying = false
    }
    
    // MARK: - Save
    
    @discardableResult
    func saveExpense(context: ModelContext) -> Bool {
        switch validator.validate(name: expenseName, amount: amount) {
        case .failure(let error):
            errorMessage = error.errorDescription
            return false
        case .success(let validated):
            let symbol = detectedCategory?.systemImage ?? "creditcard.fill"
            let tintHex = detectedCategory?.tintHex ?? "007AFF"
            let expense = Expense(name: validated.name, date: date, amount: validated.amount,
                                  expenseSymbol: symbol, expenseTintHex: tintHex)
            context.insert(expense)
            do {
                try context.save()
                return true
            } catch {
                errorMessage = "Failed to save expense: \(error.localizedDescription)"
                return false
            }
        }
    }
}
