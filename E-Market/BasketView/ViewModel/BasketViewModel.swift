//
//  BasketViewModel.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import Foundation

final class BasketViewModel {
    static let shared = BasketViewModel()
    private(set) var items: [BasketItem] = []
    
    var totalPrice: Double {
        items.reduce(0) { $0 + (Double($1.quantity) * $1.product.priceValue) }
    }
    
    func addToBasket(product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(BasketItem(product: product, quantity: 1))
        }
        NotificationCenter.default.post(name: .basketUpdated, object: nil)
    }
    
    func updateQuantity(for item: BasketItem, change: Int) {
        guard let index = items.firstIndex(where: { $0.product.id == item.product.id }) else { return }
        items[index].quantity += change
        if items[index].quantity <= 0 {
            items.remove(at: index)
        }
        NotificationCenter.default.post(name: .basketUpdated, object: nil)
    }
    
    func clearBasket() {
        items.removeAll()
        NotificationCenter.default.post(name: .basketUpdated, object: nil)
    }
}

struct BasketItem {
    let product: Product
    var quantity: Int
}
