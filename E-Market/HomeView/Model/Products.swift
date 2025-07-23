//
//  Products.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import Foundation

// MARK: - ProductElement
struct Product: Codable {
    let createdAt: String
    let name: String
    let image: String
    let price: String
    let description: String
    let model: String
    let brand: String
    let id: String
    var priceValue: Double {
        return Double(price) ?? 0.0
    }
}

