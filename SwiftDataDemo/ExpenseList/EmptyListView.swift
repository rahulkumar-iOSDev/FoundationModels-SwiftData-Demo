//
//  EmptyListView.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 26/09/26.
//

import SwiftUI

// MARK: - Empty State View

struct EmptyListView: View {
    @Binding var isShowingAddExpenseSheet: Bool

    // Animation drivers
    @State private var float: Bool = false
    @State private var glowPulse: Bool = false
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // MARK: Animated icon
            ZStack {
                // Soft pulsing halo
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.accentColor.opacity(0.35),
                                Color.accentColor.opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(glowPulse ? 1.15 : 0.9)
                    .opacity(glowPulse ? 0.9 : 0.5)

                // Main icon badge
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
                        )

                    Image(systemName: "list.bullet.rectangle.portrait")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.accentColor,
                                    Color.accentColor.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .offset(y: float ? -6 : 6)
            }
            .frame(height: 200)

            // MARK: Title + description
            VStack(spacing: 8) {
                Text("No Expenses Yet")
                    .font(.title3.weight(.semibold))

                Text("Start adding expense to see your list.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)

            // MARK: CTA button
            Button {
                isShowingAddExpenseSheet = true
            } label: {
                Label("Add Expense", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.glassProminent)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
        }
        .padding(.horizontal, 24)
        .onAppear {
            // Continuous animations
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                float = true
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            // Entry animation
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.05)) {
                appeared = true
            }
        }
    }
}
