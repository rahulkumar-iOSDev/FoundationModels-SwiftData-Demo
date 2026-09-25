//
//  AddExpenseView.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 23/09/26.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddExpenseViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        TextField("Expense name", text: $viewModel.expenseName)
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
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: viewModel.expenseName) {
                await viewModel.classify(viewModel.expenseName)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if viewModel.saveExpense(context: context) {
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
    return AddExpenseView()
}
