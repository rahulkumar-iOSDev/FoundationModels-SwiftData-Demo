//
//  UpdateExpense.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import SwiftUI
import SwiftData

struct UpdateExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var expense: Expense

    @State private var detectedCategory: ExpenseCategory?
    @State private var isClassifying: Bool = false
    @State private var hasAppeared: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        TextField("Expense name", text: $expense.name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(false)

                        trailingIcon
                    }
                } footer: {
                    if let category = displayCategory {
                        Text("Detected as **\(category.rawValue)**")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                DatePicker("Date", selection: $expense.date, displayedComponents: .date)

                HStack(spacing: 4) {
                    Text("₹")
                        .foregroundStyle(.secondary)
                    TextField("Amount", value: $expense.amount, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                }
            }
            .navigationTitle("Update Expense")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Pre-populate category from stored symbol — no AI call
                detectedCategory = ExpenseCategory.allCases.first {
                    $0.systemImage == expense.expenseSymbol
                }
            }
            .task(id: expense.name) {
                // Skip the very first run so no AI fires on appear
                if !hasAppeared {
                    hasAppeared = true
                    return
                }
                await classify(expense.name)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Display Helpers

    private var isNameEmpty: Bool {
        expense.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var displayCategory: ExpenseCategory? {
        isNameEmpty ? nil : detectedCategory
    }

    @ViewBuilder
    private var trailingIcon: some View {
        if isClassifying {
            ProgressView()
                .controlSize(.small)
                .frame(width: 28, height: 28)
        } else if let category = displayCategory {
            Image(systemName: category.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(category.tint.gradient))
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Detected category: \(category.rawValue)")
        }
    }

    // MARK: - Classification

    private func classify(_ name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            detectedCategory = nil
            isClassifying = false
            return
        }

        isClassifying = true
        defer { isClassifying = false }

        let category = await ExpenseClassifier.shared.classify(name)
        if Task.isCancelled { return }

        withAnimation(.easeInOut(duration: 0.2)) {
            detectedCategory = category
            if let category {
                expense.expenseSymbol = category.systemImage
                expense.expenseTintHex = category.tintHex
            }
        }
    }
}

#Preview {
    let mockExpense = Expense(
        name: "Lunch",
        date: Date(),
        amount: 500,
        expenseSymbol: "fork.knife",
        expenseTintHex: "FF9500"
    )
    return UpdateExpenseView(expense: mockExpense)
}
