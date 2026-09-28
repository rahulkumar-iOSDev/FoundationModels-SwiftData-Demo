//
//  UpdateExpenseViewModel.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class UpdateExpenseViewModel {
    /// The original, context-tracked model — not mutated until saveChanges() succeeds.
    private let expense: Expense

    // MARK: - Local Draft State (safe to mutate freely, no autosave risk)
    var name: String
    var date: Date
    var amount: String

    // MARK: - Classification State
    var detectedCategory: ExpenseCategory?
    var isClassifying: Bool = false
    private var hasAppeared: Bool = false
    
    private var currentClassificationID: UUID?

    // MARK: - Validation State
    var errorMessage: String?
    private let validator: ExpenseValidation

    init(expense: Expense, validator: ExpenseValidation = ExpenseValidation()) {
        self.expense = expense
        self.validator = validator

        // Seed local draft from the existing model — this is the "copy"
        self.name = expense.name
        self.date = expense.date
        self.amount = String(expense.amount)
    }

    // MARK: - Display Helpers

    var isNameEmpty: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var displayCategory: ExpenseCategory? {
        isNameEmpty ? nil : detectedCategory
    }

    var isSaveDisabled: Bool {
        amount.isEmpty || name.isEmpty
    }

    // MARK: - Lifecycle

    func onAppear() {
        // Pre-populate category from stored symbol — no AI call
        detectedCategory = ExpenseCategory.allCases.first {
            $0.systemImage == expense.expenseSymbol
        }
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

    /// Validates the local draft, then writes it back onto the real `expense` and persists.
    @discardableResult
       func saveChanges(context: ModelContext) -> Bool {
           switch validator.validate(name: name, amount: amount) {
           case .failure(let error):
               errorMessage = error.errorDescription
               return false
           case .success(let validated):
               expense.name = validated.name
               expense.amount = validated.amount
               expense.date = date
               if let category = detectedCategory {
                   expense.expenseSymbol = category.systemImage
                   expense.expenseTintHex = category.tintHex
               }
               do {
                   try context.save()
                   return true
               } catch {
                   errorMessage = "Failed to save changes: \(error.localizedDescription)"
                   return false
               }
           }
       }
}
