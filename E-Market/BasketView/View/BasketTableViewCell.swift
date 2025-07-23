//
//  BasketTableViewCell.swift
//  E-Market
//
//  Created by Mine Korkmaz on 22.07.2025.
//

import UIKit

class BasketTableViewCell: UITableViewCell {

    @IBOutlet weak var maxButton: UIButton!
    @IBOutlet weak var minButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    static let identifier = "BasketTableViewCell"
    var increaseQuantity: (() -> Void)?
        var decreaseQuantity: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with item: BasketItem) {
            nameLabel.text = item.product.name
            countLabel.text = "\(item.quantity)"
            priceLabel.text = "\(item.product.priceValue * Double(item.quantity)) ₺"
        }
    
    @IBAction func maxButtonTapped(_ sender: Any) {
        increaseQuantity?()
    }
    @IBAction func minButtonTapped(_ sender: Any) {
        decreaseQuantity?()
    }
}
