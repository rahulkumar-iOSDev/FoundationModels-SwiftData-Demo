//
//  ExpenseValidator.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import Foundation
enum ExpenseValidationError: LocalizedError, Equatable {
    case emptyName
    case invalidAmount

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Expense name can't be empty."
        case .invalidAmount:
            return "Amount must be greater than 1."
        }
    }
}

struct ValidatedExpenseInput {
    let name: String
    let amount: Double
}

final class ExpenseValidation {

    /// Minimum amount an expense must exceed to be valid.
    private let minimumAmount: Double

    init(minimumAmount: Double = 1) {
        self.minimumAmount = minimumAmount
    }

    /// Validates raw form input and returns a cleaned, typed result on success.
    func validate(name: String, amount: String) -> Result<ValidatedExpenseInput, ExpenseValidationError> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return .failure(.emptyName)
        }

        guard let amountValue = Double(amount), amountValue > minimumAmount else {
            return .failure(.invalidAmount)
        }

        return .success(ValidatedExpenseInput(name: trimmedName, amount: amountValue))
    }

    // MARK: - Individual field checks (useful for inline/live field validation)

    func isNameValid(_ name: String) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func isAmountValid(_ amount: String) -> Bool {
        guard let value = Double(amount) else { return false }
        return value > minimumAmount
    }
}


extension ExpenseValidation {
    /// Overload for call sites where amount is already a Double (e.g. editing an existing model).
    func validate(name: String, amount: Double) -> Result<ValidatedExpenseInput, ExpenseValidationError> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return .failure(.emptyName)
        }

        guard amount > minimumAmount else {
            return .failure(.invalidAmount)
        }

        return .success(ValidatedExpenseInput(name: trimmedName, amount: amount))
    }

    func isAmountValid(_ amount: Double) -> Bool {
        amount > minimumAmount
    }
}
