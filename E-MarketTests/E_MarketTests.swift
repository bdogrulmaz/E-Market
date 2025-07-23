//
//  E_MarketTests.swift
//  E-MarketTests
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import Testing
@testable import E_Market

struct E_MarketTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test
    func testHomeViewModelShowsCorrectProducts() async throws {
        var viewModel = HomesViewModel()
        let product1 = Product(createdAt: "", name: "Ürün 1", image: "", price: "10", description: "", model: "", brand: "", id: "1")
        let product2 = Product(createdAt: "", name: "Ürün 2", image: "", price: "20", description: "", model: "", brand: "", id: "2")
        viewModel.products = [product1, product2]
        #expect(viewModel.products.count == 2)
        #expect(viewModel.products[0].name == "Ürün 1")
        #expect(viewModel.products[1].name == "Ürün 2")
    }

    @Test
    func testBasketViewModelAddAndRemoveProduct() async throws {
        let basket = BasketViewModel.shared
        basket.clearBasket()
        let product = Product(createdAt: "", name: "Sepet Ürünü", image: "", price: "15", description: "", model: "", brand: "", id: "3")
        basket.addToBasket(product: product)
        #expect(basket.items.count == 1)
        #expect(basket.items[0].product.id == "3")
        #expect(basket.items[0].quantity == 1)
        basket.addToBasket(product: product)
        #expect(basket.items[0].quantity == 2)
        basket.updateQuantity(for: basket.items[0], change: -2)
        #expect(basket.items.isEmpty)
    }

    @Test
    func testFavoritesAddAndRemove() async throws {
        var viewModel = HomesViewModel()
        let product = Product(createdAt: "", name: "Favori Ürün", image: "", price: "30", description: "", model: "", brand: "", id: "4")
        #expect(viewModel.favoriteProducts.isEmpty)
        viewModel.toggleFavorite(for: product)
        #expect(viewModel.favoriteProducts.contains(where: { $0.id == "4" }))
        viewModel.toggleFavorite(for: product)
        #expect(!viewModel.favoriteProducts.contains(where: { $0.id == "4" }))
    }

}
