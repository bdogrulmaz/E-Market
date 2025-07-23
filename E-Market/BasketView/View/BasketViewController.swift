//
//  BasketViewController.swift
//  E-Market
//
//  Created by Mine Korkmaz on 21.07.2025.
//

import UIKit

final class BasketViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    var viewModel: BasketViewModel! = BasketViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupEmptyStateView()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.reloadData()
        updateTotalPrice()
        updateEmptyState()
        updateBasketBadge()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "BasketTableViewCell", bundle: nil), forCellReuseIdentifier: "BasketTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateEmptyState() {
        guard let viewModel = viewModel else {
            emptyStateView.isHidden = false
            tableView.isHidden = true
            bottomView.isHidden = false
            return
        }
        let hasBasketItems = !viewModel.items.isEmpty
        emptyStateView.isHidden = hasBasketItems
        tableView.isHidden = !hasBasketItems
        bottomView.isHidden = !hasBasketItems
    }
    
    private func setupEmptyStateView() {
        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private let emptyStateView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = "Sepetinizde henüz ürün mevcut değil"
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -20)
        ])
        container.isHidden = true
        return container
    }()
    
    private func updateTotalPrice() {
        totalPriceLabel.text = "Toplam: \(viewModel.totalPrice) ₺"
    }
    
    private func updateBasketBadge() {
        let count = viewModel.items.count
        if let tabBarController = self.tabBarController {
            let basketTab = tabBarController.tabBar.items?[1]
            basketTab?.badgeValue = count > 0 ? "\(count)" : nil
        }
    }
    
    @IBAction func completeButtonClicked(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Uyarı",
            message: "Devamı, işe alım süreci tamamlandıktan sonra :)",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension BasketViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateEmptyState()
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BasketTableViewCell.identifier, for: indexPath) as! BasketTableViewCell
        let item = viewModel.items[indexPath.row]
        cell.configure(with: item)
        cell.increaseQuantity = { [weak self] in
            guard let self = self else { return }
            self.viewModel.updateQuantity(for: item, change: 1)
            self.tableView.reloadData()
            self.updateTotalPrice()
            self.updateBasketBadge()
        }
        cell.decreaseQuantity = { [weak self] in
            guard let self = self else { return }
            self.viewModel.updateQuantity(for: item, change: -1)
            self.tableView.reloadData()
            self.updateTotalPrice()
            self.updateBasketBadge()
        }
        return cell
    }
}


