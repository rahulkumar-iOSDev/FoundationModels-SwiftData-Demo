//
//  UpdateExpense.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import SwiftUI
import SwiftData
import FoundationModels

struct UpdateExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var expense: Expense

    // AI session
    private let session = LanguageModelSession {
        "You are an assistant that classifies expense descriptions into one category."
    }

    @State private var detectedCategory: ExpenseCategory?
    @State private var isClassifying: Bool = false

    @State private var hasAppeared: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Expense Name + AI-detected icon
                Section {
                    HStack(spacing: 10) {
                        TextField("Expense name", text: $expense.name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(false)

                        trailingIcon
                    }
                } footer: {
                    if let category = detectedCategory, !expense.name.isEmpty {
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
                detectedCategory = ExpenseCategory.allCases.first {
                    $0.systemImage == expense.expenseSymbol
                }
            }
            .task(id: expense.name) {
                if !hasAppeared {
                    hasAppeared = true
                    return
                }
                await detectCategory(for: expense.name)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Trailing Icon (right of name field)

    @ViewBuilder
    private var trailingIcon: some View {
        if isClassifying {
            ProgressView()
                .controlSize(.small)
                .frame(width: 28, height: 28)
        } else if let category = detectedCategory {
            Image(systemName: category.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(category.tint.gradient))
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Detected category: \(category.rawValue)")
        }
    }

    // MARK: - AI Classification

    private func detectCategory(for name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            detectedCategory = nil
            isClassifying = false
            return
        }

        // Debounce — 400ms
        try? await Task.sleep(nanoseconds: 400_000_000)
        if Task.isCancelled { return }

        isClassifying = true
        defer { isClassifying = false }

        // Fall back to keyword classifier if AI is unavailable
        guard SystemLanguageModel.default.availability == .available else {
            apply(keywordFallback(for: trimmed))
            return
        }

        do {
            let response = try await session.respond(
                to: "Classify this expense: \(trimmed)",
                generating: ExpenseCategory.self
            )
            apply(response.content)
        } catch {
            apply(keywordFallback(for: trimmed))
        }
    }

    /// Apply the detected category to the model + local state.
    /// Also persists the new symbol/tint onto the Expense.
    private func apply(_ category: ExpenseCategory) {
        withAnimation(.easeInOut(duration: 0.2)) {
            detectedCategory = category
            expense.expenseSymbol = category.systemImage
            expense.expenseTintHex = category.tintHex
        }
    }

    /// Simple keyword classifier used when on-device AI is unavailable.
    private func keywordFallback(for name: String) -> ExpenseCategory {
        let lower = name.lowercased()
        if lower.contains("food") || lower.contains("grocery") || lower.contains("restaurant") || lower.contains("coffee") || lower.contains("dinner") { return .food }
        if lower.contains("movie") || lower.contains("game") || lower.contains("concert") { return .entertainment }
        if lower.contains("fuel") || lower.contains("petrol") || lower.contains("uber") || lower.contains("cab") { return .transport }
        if lower.contains("bill") || lower.contains("electric") || lower.contains("water") || lower.contains("rent") { return .bills }
        if lower.contains("doctor") || lower.contains("medicine") || lower.contains("hospital") { return .health }
        if lower.contains("flight") || lower.contains("hotel") || lower.contains("trip") || lower.contains("travel") { return .travel }
        if lower.contains("shopping") || lower.contains("cloth") || lower.contains("amazon") || lower.contains("mall") { return .shopping }
        return .other
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
