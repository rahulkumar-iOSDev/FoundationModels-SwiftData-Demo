//
//  ExpenseCell.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 26/09/26.
//

// MARK: - Expense Cell
import SwiftUI

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
