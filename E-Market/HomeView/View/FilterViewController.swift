//
//  FilterViewController.swift
//  E-Market
//
//  Created by Mine Korkmaz on 22.07.2025.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(sortIndex: Int, maxPrice: Float)
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var applyButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var topView: UIView!
    var viewModel: HomesViewModel!
    weak var delegate: FilterViewControllerDelegate?
    private let sortOptions = ["Current", "Cheap", "Expensive", "A-Z", "Z-A"]
    private var selectedSortIndex: Int = 0
    
    private let sortSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Current", "Cheap", "Expensive", "A-Z", "Z-A"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let priceSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 5000
        slider.value = 0
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Price: 0 TL"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.setupShadow(
            shadowColor: UIColor.black,
            shadowOpacity: 0.05,
            shadowOffset: CGSize(width: 0, height: 4),
            shadowRadius: 4,
            customShadowPath: UIBezierPath(
                roundedRect: topView.bounds,
                cornerRadius: topView.layer.cornerRadius
            )
        )
        setupFiltersUI()
        updateButtonsState()
        styleButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedSortIndex = viewModel.selectedSortIndex
        sortSegmentedControl.selectedSegmentIndex = selectedSortIndex
        priceSlider.value = viewModel.maxPrice
        priceLabel.text = "Price: \(Int(viewModel.maxPrice)) TL"
        updateButtonsState()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupFiltersUI() {
        view.addSubview(sortSegmentedControl)
        view.addSubview(priceSlider)
        view.addSubview(priceLabel)
        NSLayoutConstraint.activate([
            sortSegmentedControl.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 20),
            sortSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sortSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            priceSlider.topAnchor.constraint(equalTo: sortSegmentedControl.bottomAnchor, constant: 40),
            priceSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            priceSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            priceLabel.topAnchor.constraint(equalTo: priceSlider.bottomAnchor, constant: 10),
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        sortSegmentedControl.addTarget(self, action: #selector(sortOptionChanged(_:)), for: .valueChanged)
        priceSlider.addTarget(self, action: #selector(priceSliderChanged(_:)), for: .valueChanged)
    }
    
    private func styleButtons() {
        let buttons = [applyButton, clearButton]
        buttons.forEach { button in
            button?.layer.cornerRadius = 10
            button?.layer.masksToBounds = false
            button?.layer.shadowColor = UIColor.black.cgColor
            button?.layer.shadowOpacity = 0.2
            button?.layer.shadowOffset = CGSize(width: 0, height: 2)
            button?.layer.shadowRadius = 4
            button?.setTitleColor(.white, for: .normal)
        }
    }
    
    private func updateButtonsState() {
        let isSortChanged = sortSegmentedControl.selectedSegmentIndex != 0
        let isPriceChanged = priceSlider.value != 0
        let isAnyFilterActive = isSortChanged || isPriceChanged
        clearButton.isEnabled = isAnyFilterActive
        if isAnyFilterActive {
            clearButton.backgroundColor = UIColor.systemBlue
        } else {
            clearButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        }
    }
    
    @objc private func sortOptionChanged(_ sender: UISegmentedControl) {
        selectedSortIndex = sender.selectedSegmentIndex
        updateButtonsState()
    }
    
    @objc private func priceSliderChanged(_ sender: UISlider) {
        let steppedValue = round(sender.value / 50) * 50
        sender.value = steppedValue
        priceLabel.text = "Price: \(Int(steppedValue)) TL"
        updateButtonsState()
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        viewModel.selectedSortIndex = selectedSortIndex
        viewModel.maxPrice = priceSlider.value
        viewModel.applyFilters()
        delegate?.didApplyFilters(sortIndex: selectedSortIndex, maxPrice: priceSlider.value)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        sortSegmentedControl.selectedSegmentIndex = 0
        selectedSortIndex = 0
        priceSlider.value = 0
        priceLabel.text = "Price: 0 TL"
        viewModel.clearFilters()
        delegate?.didApplyFilters(sortIndex: 0, maxPrice: 0)
        updateButtonsState()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
