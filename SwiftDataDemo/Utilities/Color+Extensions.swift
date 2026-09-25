//
//  Color+Extensions.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

import SwiftUI

extension Color {
    /// Creates a Color from a 6-digit hex string (e.g. "FF9500").
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8)  & 0xFF) / 255.0
        let b = Double(value         & 0xFF) / 255.0

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}
