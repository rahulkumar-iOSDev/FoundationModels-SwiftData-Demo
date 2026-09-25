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
    static func keywordFallback(for name: String) -> ExpenseCategory {
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
