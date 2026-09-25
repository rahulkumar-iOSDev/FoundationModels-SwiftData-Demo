//
//  AddExpenseView.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 23/09/26.
//

import SwiftUI
import SwiftData
import FoundationModels

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var expenseName: String = ""
    @State private var date: Date = .now
    @State private var amount: String = ""

    @State private var detectedCategory: ExpenseCategory?
    @State private var isClassifying: Bool = false

    private let session = LanguageModelSession {
        "You are an assistant that classifies expense descriptions into one category."
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Expense Name + AI-detected icon
                Section {
                    HStack(spacing: 10) {
                        TextField("Expense name", text: $expenseName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(false)

                        trailingIcon
                    }
                } footer: {
                    if let category = detectedCategory, !expenseName.isEmpty  {
                        Text("Detected as **\(category.rawValue)**")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                DatePicker("Date", selection: $date, displayedComponents: .date)

                CurrencyAmountField(amount: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: expenseName) {
                await detectCategory(for: expenseName)
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

    // MARK: - Trailing Icon (right of text field)

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
                .background(
                    Circle().fill(category.tint.gradient)
                )
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

        // Debounce: wait 400ms before hitting the model
        try? await Task.sleep(nanoseconds: 400_000_000)
        if Task.isCancelled { return }

        isClassifying = true
        defer { isClassifying = false }

        // Availability check — fall back to keyword heuristic if AI is off
        guard SystemLanguageModel.default.availability == .available else {
            withAnimation(.easeInOut(duration: 0.2)) {
                detectedCategory = keywordFallback(for: trimmed)
            }
            return
        }

        do {
            let response = try await session.respond(
                to: "Classify this expense: \(trimmed)",
                generating: ExpenseCategory.self
            )
            withAnimation(.easeInOut(duration: 0.2)) {
                detectedCategory = response.content
            }
        } catch {
            withAnimation {
                detectedCategory = keywordFallback(for: trimmed)
            }
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

// MARK: - Preview

#Preview {
    AddExpenseView()
}

