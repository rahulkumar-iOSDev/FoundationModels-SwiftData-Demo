//
//  ExpenseClassifier.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import Foundation
import FoundationModels

/// Centralized service for classifying expense names into an `ExpenseCategory`.
///
/// Handles:
/// - The on-device `LanguageModelSession`
/// - Availability checking (Apple Intelligence support)
/// - Debouncing repeated calls
/// - Graceful fallback to keyword matching when AI is unavailable
///
/// Usage:
/// ```swift
/// let category = await ExpenseClassifier.shared.classify("Grocery")
/// ```
final class ExpenseClassifier {

    static let shared = ExpenseClassifier()

    // MARK: - Private

    private let session: LanguageModelSession
    private let debounceNanoseconds: UInt64

    private init(debounceMilliseconds: UInt64 = 400) {
        self.session = LanguageModelSession {
            "You are an assistant that classifies expense descriptions into one category."
        }
        self.debounceNanoseconds = debounceMilliseconds * 1_000_000
    }

    // MARK: - Public

    /// Classifies the given expense name into an `ExpenseCategory`.
    ///
    /// - Parameters:
    ///   - name: The expense description typed by the user.
    ///   - debounce: Whether to wait ~400ms before classifying. Set to `false`
    ///     for one-shot calls (e.g. on save) that don't need debouncing.
    /// - Returns: An `ExpenseCategory`, or `nil` if `name` is empty/whitespace.
    func classify(_ name: String, debounce: Bool = true) async -> ExpenseCategory? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Debounce (useful when called from `.task(id:)` on every keystroke)
        if debounce {
            try? await Task.sleep(nanoseconds: debounceNanoseconds)
            if Task.isCancelled { return nil }
        }

        // Fast path: if Apple Intelligence is unavailable, use keyword fallback
        guard SystemLanguageModel.default.availability == .available else {
            return Self.keywordFallback(for: trimmed)
        }

        // Try AI
        do {
            let response = try await session.respond(
                to: "Classify this expense: \(trimmed)",
                generating: ExpenseCategory.self
            )
            if Task.isCancelled { return nil }
            return response.content
        } catch {
            // Any AI failure → fall back to keyword matching
            return Self.keywordFallback(for: trimmed)
        }
    }

    // MARK: - Fallback
    /// Simple keyword-based classifier used when on-device AI is unavailable.
    /// Order matters: more specific categories are checked before broader/overlapping ones.
    static func keywordFallback(for name: String) -> ExpenseCategory {
        let lower = name.lowercased()

        func matches(_ keywords: [String]) -> Bool {
            keywords.contains { lower.contains($0) }
        }
        // MARK: Specific / narrow categories first (avoid being swallowed by broader ones)

        if matches(["coffee", "cafe", "starbucks", "tea", "chai", "snack", "bakery"]) {
            return .coffee
        }
        if matches(["grocery", "groceries", "supermarket", "vegetable", "fruits", "milk", "bigbasket", "blinkit", "zepto", "dmart"]) {
            return .groceries
        }
        if matches(["restaurant", "food", "dinner", "lunch", "breakfast", "swiggy", "zomato", "pizza", "burger", "dining"]) {
            return .food
        }
        if matches(["alcohol", "beer", "wine", "whisky", "vodka", "bar", "pub", "brewery", "liquor"]) {
            return .alcoholBars
        }

        if matches(["fuel", "petrol", "diesel", "gas station", "cng"]) {
            return .fuel
        }
        if matches(["uber", "ola", "cab", "taxi", "bus", "metro", "train ticket", "rickshaw", "auto", "parking", "toll"]) {
            return .transport
        }
        if matches(["flight", "airfare", "airline", "vacation", "trip", "tour", "visa fee"]) {
            return .travel
        }
        if matches(["hotel", "hostel", "airbnb", "resort", "stay", "lodging"]) {
            return .travelStay
        }

        if matches(["electronics", "laptop", "mobile phone", "smartphone", "gadget", "charger", "earphone", "headphone", "camera", "tv", "television"]) {
            return .electronics
        }
        if matches(["furniture", "sofa", "mattress", "wardrobe", "decor", "curtain", "home appliance", "kitchenware"]) {
            return .homeAndFurniture
        }
        if matches(["amazon", "flipkart", "myntra", "mall", "shopping", "clothes", "clothing", "shoes", "apparel", "accessories"]) {
            return .shopping
        }

        if matches(["rent", "landlord", "lease", "maintenance charge", "society fee"]) {
            return .rent
        }
        if matches(["electricity", "electric bill", "water bill", "gas bill", "utility", "utilities"]) {
            return .bills
        }
        if matches(["mobile recharge", "internet bill", "broadband", "wifi bill", "airtel", "jio", "vodafone", "data plan"]) {
            return .mobileInternet
        }
        if matches(["subscription", "netflix", "spotify", "prime video", "hotstar", "youtube premium", "membership"]) {
            return .subscriptions
        }

        if matches(["doctor", "hospital", "medicine", "pharmacy", "clinic", "surgery", "dentist", "diagnos"]) {
            return .health
        }
        if matches(["gym", "yoga", "fitness", "workout", "personal trainer", "sports club"]) {
            return .fitness
        }
        if matches(["salon", "haircut", "spa", "parlour", "cosmetics", "skincare", "grooming"]) {
            return .personalCare
        }

        if matches(["school fee", "college fee", "tuition", "course", "exam fee", "books", "education", "training"]) {
            return .education
        }
        if matches(["daycare", "babysitter", "kids", "school supplies", "toys", "family outing"]) {
            return .kidsAndFamily
        }
        if matches(["pet", "vet", "dog food", "cat food", "grooming pet", "pet store"]) {
            return .pets
        }

        if matches(["insurance", "premium", "policy"]) {
            return .insurance
        }
        if matches(["mutual fund", "sip", "stock", "investment", "fd", "fixed deposit", "shares", "crypto"]) {
            return .investment
        }
        if matches(["emi", "loan", "installment", "credit card bill", "repayment"]) {
            return .loanEMI
        }
        if matches(["bank fee", "atm charge", "service charge", "penalty", "late fee"]) {
            return .bankFees
        }
        if matches(["tax", "gst", "income tax", "tds"]) {
            return .taxes
        }
        if matches(["gift", "donation", "charity", "wedding gift", "birthday gift"]) {
            return .giftsDonations
        }

        if matches(["office", "stationery", "printer", "coworking", "work supplies", "conference"]) {
            return .officeWork
        }
        if matches(["movie", "cinema", "game", "concert", "netflix ticket", "amusement", "event ticket", "streaming"]) {
            return .entertainment
        }
        return .other
    }
}
