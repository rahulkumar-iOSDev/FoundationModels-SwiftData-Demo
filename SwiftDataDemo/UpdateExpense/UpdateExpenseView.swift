//
//  UpdateExpense.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import SwiftUI
import SwiftData

struct UpdateExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: UpdateExpenseViewModel

    init(expense: Expense) {
        _viewModel = State(initialValue: UpdateExpenseViewModel(expense: expense))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        TextField("Expense name", text: $viewModel.name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(false)

                        trailingIcon
                    }
                } footer: {
                    if let category = viewModel.displayCategory {
                        Text("Detected as **\(category.rawValue)**")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)

                HStack(spacing: 4) {
                    Text("₹")
                        .foregroundStyle(.secondary)
                    TextField("Amount", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                }
            }
            .navigationTitle("Update Expense")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.onAppear()
            }
            .task(id: viewModel.name) {
                await viewModel.classify(viewModel.name)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if viewModel.saveChanges(context: context) {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isSaveDisabled)
                }
            }
            .alert(
                "Couldn't Save",
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

    @ViewBuilder
    private var trailingIcon: some View {
        if viewModel.isClassifying {
            ProgressView()
                .controlSize(.small)
                .frame(width: 28, height: 28)
        } else if let category = viewModel.displayCategory {
            Image(systemName: category.systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(category.tint.gradient))
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Detected category: \(category.rawValue)")
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
