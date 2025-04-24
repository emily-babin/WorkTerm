//
//  CustomHeaderView.swift
//  Respectful Spaces
//
//  Created by Babin,Emily on 2025-04-23.
//
// Controls the header bar that appears at the top of the app

import UIKit

protocol CustomHeaderViewDelegate: AnyObject {
    func didTapMenuButton()
}

class CustomHeaderView: UIView {
    weak var delegate: CustomHeaderViewDelegate?
    
    let menuButton = UIButton(type: .system)
    let titleLabel = UILabel()
    let logoImageView = UIImageView()
    var titleText: String = "" {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    
    private func setupView() {
        backgroundColor = .systemGray5
        
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .label
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(menuButton)
        
        titleLabel.text = "Page Title"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        logoImageView.image = UIImage(named: "yellowHexagon")
        logoImageView.tintColor = .label
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            menuButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            menuButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 24),
            menuButton.heightAnchor.constraint(equalToConstant: 24),
            
            logoImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        
    }

    @objc private func menuButtonTapped() {
        delegate?.didTapMenuButton()
    }
    
}
