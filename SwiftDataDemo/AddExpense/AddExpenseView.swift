//
//  AddExpenseView.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 23/09/26.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var expenseName: String = ""
    @State private var date: Date = .now
    @State private var amount: String = ""

    @State private var detectedCategory: ExpenseCategory?
    @State private var isClassifying: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        TextField("Expense name", text: $expenseName)
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

                DatePicker("Date", selection: $date, displayedComponents: .date)

                HStack(spacing: 4) {
                    Text("₹")
                        .foregroundStyle(.secondary)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: expenseName) {
                await classify(expenseName)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveExpense() }
                        .disabled(amount.isEmpty || expenseName.isEmpty)
                }
            }
        }
    }

    // MARK: - Display Helpers

    private var isNameEmpty: Bool {
        expenseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
        }
    }

    // MARK: - Save

    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        let symbol = detectedCategory?.systemImage ?? "creditcard.fill"
        let tintHex = detectedCategory?.tintHex ?? "007AFF"

        let expense = Expense(
            name: expenseName,
            date: date,
            amount: amountValue,
            expenseSymbol: symbol,
            expenseTintHex: tintHex
        )
        context.insert(expense)
        dismiss()
    }
}

#Preview {
    AddExpenseView()
}

