//
//  Expense.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 23/09/26.
//

import Foundation
import SwiftData
import FoundationModels
import SwiftUI

@Model
class Expense: Identifiable {
    @Attribute(.unique) var name: String
    var date: Date
    var amount: Double
    var expenseSymbol: String?
    var expenseTintHex: String?

    init(name: String,
         date: Date,
         amount: Double,
         expenseSymbol: String? = "creditcard.fill",
         expenseTintHex: String? = "007AFF") {
        self.name = name
        self.date = date
        self.amount = amount
        self.expenseSymbol = expenseSymbol
        self.expenseTintHex = expenseTintHex
    }
}

@Generable
enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food          = "Food & Dining"
    case travel        = "Travel"
    case shopping      = "Shopping"
    case bills         = "Bills & Utilities"
    case entertainment = "Entertainment"
    case health        = "Health"
    case transport     = "Transport"
    case other         = "Other"

    var id: String { rawValue }

    /// SF Symbol name for this category.
    var systemImage: String {
        switch self {
        case .food:          return "fork.knife"
        case .travel:        return "airplane"
        case .shopping:      return "cart.fill"
        case .bills:         return "doc.text.fill"
        case .entertainment: return "film.fill"
        case .health:        return "heart.fill"
        case .transport:     return "car.fill"
        case .other:         return "creditcard.fill"
        }
    }

    /// Tint stored/passed as a 6-digit hex string.
    var tintHex: String {
        switch self {
        case .food:          return "FF9500"   // orange
        case .travel:        return "007AFF"   // blue
        case .shopping:      return "34C759"   // green
        case .bills:         return "FF3B30"   // red
        case .entertainment: return "AF52DE"   // purple
        case .health:        return "FF2D55"   // pink
        case .transport:     return "30B0C7"   // teal
        case .other:         return "8E8E93"   // gray
        }
    }

    /// Convenience: `Color` built from `tintHex`, for UI rendering only.
    var tint: Color { Color(hex: tintHex) }
}
