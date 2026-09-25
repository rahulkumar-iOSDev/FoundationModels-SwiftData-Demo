//
//  CurrencyFormatter.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import Foundation

// MARK: - Currency

enum Currency: String {
    case inr = "INR"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    
    var locale: Locale {
        switch self {
        case .inr:
            return Locale(identifier: "en_IN")
        case .usd:
            return Locale(identifier: "en_US")
        case .eur:
            return Locale(identifier: "de_DE")
        case .gbp:
            return Locale(identifier: "en_GB")
        }
    }
}


// MARK: - Currency Formatter

final class CurrencyFormatter {
    
    static func string(
        from value: Double,
        currency: Currency = .inr
    ) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = currency.locale
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}


// MARK: - Double Extension

extension Double {
    
    func currencyString(
        currency: Currency = .inr
    ) -> String {
        
        CurrencyFormatter.string(
            from: self,
            currency: currency
        )
    }
}


// MARK: - String Extension

extension String {
    
    func currencyString(
        currency: Currency = .inr
    ) -> String {
        
        guard let value = Double(self) else {
            return self
        }
        
        return CurrencyFormatter.string(
            from: value,
            currency: currency
        )
    }
}
