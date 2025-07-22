//
//  HomesViewModel.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import Foundation

final class HomesViewModel {
    
    let url = URL(string: "https://5fc9346b2af77700165ae514.mockapi.io/products")!
    var products: [Product] = []
    var favoriteProducts: [Product] = []
    var filteredProducts: [Product] = []
    var isFiltering: Bool = false
    var selectedSortIndex: Int = 0
    var maxPrice: Float = 0
    
    func fetchProducts(completion: @escaping ([Product]?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching products: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                completion(products)
            } catch {
                print("Error decoding products: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func applyFilters() {
        if maxPrice > 0 {
            filteredProducts = products.filter {
                if let priceValue = Float($0.price) {
                    return priceValue <= maxPrice
                }
                return false
            }
        } else {
            filteredProducts = products
        }
        
        switch selectedSortIndex {
        case 0:
            break
        case 1:
            filteredProducts.sort { (Float($0.price) ?? 0) < (Float($1.price) ?? 0) }
        case 2:
            filteredProducts.sort { (Float($0.price) ?? 0) > (Float($1.price) ?? 0) }
        case 3:
            filteredProducts.sort { $0.name < $1.name }
        case 4:
            filteredProducts.sort { $0.name > $1.name }
        default:
            break
        }
        isFiltering = true
    }
    
    func clearFilters() {
        selectedSortIndex = 0
        maxPrice = 0
        isFiltering = false
        filteredProducts = products
    }
    
    func toggleFavorite(for product: Product) {
        if let index = favoriteProducts.firstIndex(where: { $0.id == product.id }) {
            favoriteProducts.remove(at: index)
        } else {
            favoriteProducts.append(product)
        }
    }
    
    func isFavorite(_ product: Product) -> Bool {
        return favoriteProducts.contains(where: { $0.id == product.id })
    }
    
    func filterProducts(with searchText: String) {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 3 {
            filteredProducts = products.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
            isFiltering = true
        } else {
            filteredProducts = []
            isFiltering = false
        }
    }
}
