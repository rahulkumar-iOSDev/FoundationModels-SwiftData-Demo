//
//  Collection+Extensions.swift
//  SwiftDataDemo
//
//  Created by Rahul Kumar on 25/09/26.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
