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
