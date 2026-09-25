//
//  ExpenseSortOptions.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

enum ExpenseSortOption: String, CaseIterable, Identifiable {
    case dateNewest      = "Date (Newest First)"
    case dateOldest      = "Date (Oldest First)"
    case amountHighToLow = "Amount (High to Low)"
    case amountLowToHigh = "Amount (Low to High)"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .dateNewest, .dateOldest:
            return "calendar"
        case .amountHighToLow, .amountLowToHigh:
            return "indianrupeesign.circle"
        }
    }
}
