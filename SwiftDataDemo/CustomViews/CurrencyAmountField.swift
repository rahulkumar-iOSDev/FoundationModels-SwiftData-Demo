//
//  CurrencyAmountField.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import SwiftUI
/// A text field for entering a monetary amount with a fixed, non-editable
/// currency symbol prefix.
///
/// Usage:
/// ```
/// CurrencyAmountField(amount: $amount)
/// CurrencyAmountField(amount: $amount, currencySymbol: "$")
/// ```
struct CurrencyAmountField: View {
    @Binding var amount: String
    var currencySymbol: String = "₹"
    var placeholder: String = "0"

    var body: some View {
        HStack(spacing: 2) {
            // Non-editable currency prefix
            Text(currencySymbol)
                .foregroundStyle(.secondary)
                .font(.body.weight(.medium))

            // Editable amount
            TextField(placeholder, text: $amount)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    @Previewable @State var amount = ""
    return Form {
        CurrencyAmountField(amount: $amount)
    }
}
