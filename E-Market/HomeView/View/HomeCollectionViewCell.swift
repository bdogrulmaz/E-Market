//
//  HomeCollectionViewCell.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import UIKit

final class HomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeCollectionViewCell"
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var favoriteButtonAction: (() -> Void)?
    var addToCartAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderWidth = 1
        containerView.layer.cornerRadius = 8
        containerView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        containerView.layer.masksToBounds = false        
        imageView.contentMode = .scaleAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.setupShadow(
            shadowColor: UIColor.black,
            shadowOpacity: 0.05,
            shadowOffset: CGSize(width: 0, height: 4),
            shadowRadius: 4,
            customShadowPath: UIBezierPath(
                roundedRect: containerView.bounds,
                cornerRadius: containerView.layer.cornerRadius
            )
        )
    }
    
    @IBAction func addToCardTapped(_ sender: Any) {
        addToCartAction?()
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        favoriteButtonAction?()
    }
    
    func configure(with product: Product, isFavorite: Bool) {
        nameLabel.text = product.name
        priceLabel.text = "\(product.price) ₺"
        let starImage = UIImage(systemName: "star.fill")
        favoriteButton.setImage(starImage, for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemYellow : .lightGray
        if let url = URL(string: product.image) {
            DispatchQueue.main.async {
                self.imageView.loadImage(from: url)
            }            
        }
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UIView {
    func setupShadow(shadowColor: UIColor = .black,
                     shadowOpacity: Float = 0.1,
                     shadowOffset: CGSize = CGSize(width: 0, height: 0),
                     shadowRadius: CGFloat = 8,
                     masksToBounds: Bool = false,
                     customShadowPath: UIBezierPath? = nil) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = masksToBounds
        if let shadowPath = customShadowPath {
            layer.shadowPath = shadowPath.cgPath
        }
    }
}
