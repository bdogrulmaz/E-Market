//
//  DetailViewController.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerNameLabel: UILabel!    
    @IBOutlet weak var favoriteButton: UIButton!
    var product: Product?
    var viewModel: HomesViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        updateFavoriteButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func configureView() {
        guard let product = product else { return }
        nameLabel.text = product.name
        headerNameLabel.text = product.name
        descriptionLabel.text = product.description
        priceLabel.text = "\(product.price) ₺"
        if let url = URL(string: product.image) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                        self.imageView.contentMode = .scaleToFill
                    }
                }
            }
        }
    }
    
    private func updateFavoriteButton() {
        guard let product = product else { return }
        let isFavorite = viewModel.isFavorite(product)
        let image = UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate)
        favoriteButton.setImage(image, for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemYellow : .lightGray
    }
    
    @IBAction func addToCardTapped(_ sender: Any) {
        guard let product = product else { return }
        BasketViewModel.shared.addToBasket(product: product)
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        guard let product = product else { return }
        viewModel.toggleFavorite(for: product)
        updateFavoriteButton()
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
