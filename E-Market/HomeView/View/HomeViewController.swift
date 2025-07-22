//
//  ViewController.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import UIKit

final class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var viewModel: HomesViewModel!
    var basketViewModel = BasketViewModel.shared
    
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = HomesViewModel()
        }
        setupCollectionView()
        setupLoadingView()
        fetchData()
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        let detailVC = FilterViewController(nibName: "FilterViewController", bundle: nil)
        detailVC.delegate = self
        detailVC.viewModel = self.viewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchData() {
        showLoading(true)
        viewModel.fetchProducts { [weak self] fetchedProducts in
            guard let self = self, let fetchedProducts = fetchedProducts else { 
                DispatchQueue.main.async { self?.showLoading(false) }
                return 
            }
            self.viewModel.products = fetchedProducts
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.showLoading(false)
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
        }
        let nib = UINib(nibName: String(describing: HomeCollectionViewCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
    }
    
    func updateSearchEmptyView() {
        if viewModel.isFiltering && viewModel.filteredProducts.isEmpty {
            if collectionView.backgroundView == nil {
                let container = UIView(frame: collectionView.bounds)
                let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
                imageView.tintColor = .gray
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                let label = UILabel()
                label.text = "Arama sonucu bulunamadı"
                label.textColor = .gray
                label.font = UIFont.systemFont(ofSize: 16)
                label.textAlignment = .center
                label.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(imageView)
                container.addSubview(label)
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -20),
                    imageView.widthAnchor.constraint(equalToConstant: 40),
                    imageView.heightAnchor.constraint(equalToConstant: 40),
                    label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
                    label.centerXAnchor.constraint(equalTo: container.centerXAnchor)
                ])
                collectionView.backgroundView = container
            }
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    private func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterProducts(with: searchText)
        collectionView.reloadData()
        updateSearchEmptyView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.filterProducts(with: "")
        collectionView.reloadData()
        updateSearchEmptyView()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.isFiltering {
            return viewModel.filteredProducts.count
        } else {
            return viewModel.products.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.identifier, for: indexPath) as! HomeCollectionViewCell
        let product: Product
        if viewModel.isFiltering {
            product = viewModel.filteredProducts[indexPath.item]
        } else {
            product = viewModel.products[indexPath.item]
        }
        cell.configure(with: product, isFavorite: viewModel.isFavorite(product))
        cell.favoriteButtonAction = { [weak self] in
            guard let self = self else { return }
            self.viewModel.toggleFavorite(for: product)
            collectionView.reloadItems(at: [indexPath])
        }
        cell.addToCartAction = { [weak self] in
            self?.basketViewModel.addToBasket(product: product)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = viewModel.products[indexPath.item]
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.product = selectedProduct
        detailVC.viewModel = self.viewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let spacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        
        let availableWidth = collectionView.bounds.width - insets.left - insets.right - spacing
        let cellWidth = availableWidth / 2
        
        return CGSize(width: cellWidth, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension HomeViewController: FilterViewControllerDelegate {
    func didApplyFilters(sortIndex: Int, maxPrice: Float) {
        viewModel.selectedSortIndex = sortIndex
        viewModel.maxPrice = maxPrice
        if sortIndex == 0 && maxPrice == 0 {
            viewModel.clearFilters()
        } else {
            viewModel.applyFilters()
        }
        collectionView.reloadData()
        updateSearchEmptyView()
    }
}
