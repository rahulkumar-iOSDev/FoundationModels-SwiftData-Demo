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
    case groceries      = "Groceries"
    case food           = "Food & Dining"
    case coffee         = "Coffee & Snacks"
    case travel         = "Travel"
    case transport      = "Transport"
    case fuel           = "Fuel"
    case shopping       = "Shopping"
    case electronics    = "Electronics & Gadgets"
    case homeAndFurniture = "Home & Furniture"
    case bills          = "Bills & Utilities"
    case mobileInternet = "Mobile & Internet"
    case subscriptions  = "Subscriptions"
    case rent           = "Rent & Housing"
    case entertainment  = "Entertainment"
    case health         = "Health & Medical"
    case fitness        = "Fitness & Wellness"
    case personalCare   = "Personal Care"
    case education      = "Education"
    case kidsAndFamily  = "Kids & Family"
    case pets           = "Pets"
    case insurance      = "Insurance"
    case investment     = "Investment & Savings"
    case loanEMI        = "Loan & EMI"
    case bankFees       = "Bank & Fees"
    case taxes          = "Taxes"
    case giftsDonations = "Gifts & Donations"
    case travelStay     = "Hotel & Stay"
    case officeWork     = "Office & Work"
    case alcoholBars    = "Alcohol & Bars"
    case other          = "Other Expense"

    var id: String { rawValue }

    /// SF Symbol name for this category.
    var systemImage: String {
        switch self {
        case .groceries:        return "basket.fill"
        case .food:             return "fork.knife"
        case .coffee:           return "cup.and.saucer.fill"
        case .travel:           return "airplane"
        case .transport:        return "car.fill"
        case .fuel:             return "fuelpump.fill"
        case .shopping:         return "cart.fill"
        case .electronics:      return "desktopcomputer"
        case .homeAndFurniture: return "sofa.fill"
        case .bills:            return "doc.text.fill"
        case .mobileInternet:   return "wifi"
        case .subscriptions:    return "arrow.triangle.2.circlepath.circle.fill"
        case .rent:             return "house.fill"
        case .entertainment:    return "film.fill"
        case .health:           return "cross.case.fill"
        case .fitness:          return "figure.run"
        case .personalCare:     return "scissors"
        case .education:        return "graduationcap.fill"
        case .kidsAndFamily:    return "figure.2.and.child.holdinghands"
        case .pets:             return "pawprint.fill"
        case .insurance:        return "shield.lefthalf.filled"
        case .investment:       return "chart.line.uptrend.xyaxis"
        case .loanEMI:          return "banknote.fill"
        case .bankFees:         return "building.columns.fill"
        case .taxes:            return "percent"
        case .giftsDonations:   return "gift.fill"
        case .travelStay:       return "bed.double.fill"
        case .officeWork:       return "briefcase.fill"
        case .alcoholBars:      return "wineglass.fill"
        case .other:            return "creditcard.fill"
        }
    }

    /// Tint stored/passed as a 6-digit hex string.
    var tintHex: String {
        switch self {
        case .groceries:        return "34C759"   // green
        case .food:             return "FF9500"   // orange
        case .coffee:           return "A2845E"   // brown
        case .travel:           return "007AFF"   // blue
        case .transport:        return "30B0C7"   // teal
        case .fuel:             return "FF6200"   // deep orange
        case .shopping:         return "FF3B30"   // red
        case .electronics:      return "5AC8FA"   // light blue
        case .homeAndFurniture: return "C69C6D"   // tan
        case .bills:            return "FFCC00"   // yellow
        case .mobileInternet:   return "64D2FF"   // cyan
        case .subscriptions:    return "BF5AF2"   // light purple
        case .rent:             return "8E8E93"   // gray
        case .entertainment:    return "AF52DE"   // purple
        case .health:           return "FF2D55"   // pink
        case .fitness:          return "32D74B"   // bright green
        case .personalCare:     return "FF9F0A"   // amber
        case .education:        return "0A84FF"   // indigo-blue
        case .kidsAndFamily:    return "FF6B9D"   // rose
        case .pets:             return "AC8E68"   // taupe
        case .insurance:        return "5856D6"   // indigo
        case .investment:       return "30D158"   // emerald
        case .loanEMI:          return "D70015"   // dark red
        case .bankFees:         return "6E6E73"   // dark gray
        case .taxes:            return "3A3A3C"   // charcoal
        case .giftsDonations:   return "FF375F"   // magenta-red
        case .travelStay:       return "40C8E0"   // aqua
        case .officeWork:       return "8A8A8E"   // slate gray
        case .alcoholBars:      return "9B59B6"   // wine purple
        case .other:            return "8E8E93"   // gray
        }
    }

    /// Convenience: `Color` built from `tintHex`, for UI rendering only.
    var tint: Color { Color(hex: tintHex) }
}
