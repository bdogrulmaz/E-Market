//
//  HomesViewModel.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import Foundation
import CoreData
import UIKit

final class HomesViewModel {
    
    let url = URL(string: "https://5fc9346b2af77700165ae514.mockapi.io/products")!
    var products: [Product] = []
    var favoriteProducts: [Product] = []
    var filteredProducts: [Product] = []
    var isFiltering: Bool = false
    var selectedSortIndex: Int = 0
    var maxPrice: Float = 0
    
    init() {
        loadFavorites()
    }
    
    func fetchProducts(completion: @escaping ([Product]?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", product.id)
        do {
            let results = try context.fetch(fetchRequest)
            if let existingFavorite = results.first {
                context.delete(existingFavorite)
            } else {
                let favorite = FavoriteProduct(context: context)
                favorite.id = product.id
                favorite.name = product.name
                favorite.price = product.priceValue
                favorite.image = product.image
                favorite.brand = product.brand
                favorite.model = product.model
                favorite.descriptionText = product.description
                favorite.createdAt = product.createdAt
            }
            try context.save()
            loadFavorites()
        } catch {
            
        }
    }
    
    func loadFavorites() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        do {
            let favorites = try context.fetch(fetchRequest)
            self.favoriteProducts = favorites.map {
                Product(
                    createdAt: $0.createdAt ?? "",
                    name: $0.name ?? "",
                    image: $0.image ?? "",
                    price: String($0.price),
                    description: $0.descriptionText ?? "",
                    model: $0.model ?? "",
                    brand: $0.brand ?? "",
                    id: $0.id ?? ""
                )
            }
        } catch {
            
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
