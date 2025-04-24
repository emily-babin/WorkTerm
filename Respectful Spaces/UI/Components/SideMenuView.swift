//
//  SideMenuView.swift
//  Respectful Spaces
//
//  Created by Babin,Emily on 2025-04-24.
//

import UIKit

protocol SideMenuDelegate: AnyObject {
    func didSelectMenuOption(_ option: SideMenuOption)
}

enum SideMenuOption {
    case settings
    case about
}

class SideMenuView: UIView {

    weak var delegate: SideMenuDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .systemGray6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 3, height: 0)
        layer.shadowRadius = 6

        // Settings Button
        let settingsButton = UIButton(type: .system)
        var settingsConfig = UIButton.Configuration.plain()
        settingsConfig.title = "Settings"
        settingsConfig.image = UIImage(systemName: "gearshape")
        settingsConfig.imagePadding = 10
        settingsConfig.baseForegroundColor = .label
        settingsConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        settingsButton.configuration = settingsConfig
        settingsButton.contentHorizontalAlignment = .leading
        settingsButton.addTarget(self, action: #selector(settingsTapped(_:)), for: .touchUpInside)

        print("Settings button added")
        
        // About Button
        let aboutButton = UIButton(type: .system)
        var aboutConfig = UIButton.Configuration.plain()
        aboutConfig.title = "About"
        aboutConfig.image = UIImage(systemName: "info.circle")
        aboutConfig.imagePadding = 10
        aboutConfig.baseForegroundColor = .label
        aboutConfig.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        aboutButton.configuration = aboutConfig
        aboutButton.contentHorizontalAlignment = .leading
        aboutButton.addTarget(self, action: #selector(aboutTapped(_:)), for: .touchUpInside)

        print("About button added")
        
        // Stack View to hold buttons
        let stackView = UIStackView(arrangedSubviews: [settingsButton, aboutButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 100)
        ])

    }

    @objc private func settingsTapped(_ sender: UIButton) {
        print("Settings tapped")
        let fileName = (NSString(string: #file).lastPathComponent)
        print("Triggered at \(fileName), line \(#line)")

        animateButtonTap(sender)
        delegate?.didSelectMenuOption(.settings)
    }

    @objc private func aboutTapped(_ sender: UIButton) {
        print("About tapped")
        let fileName = (NSString(string: #file).lastPathComponent)
        print("Triggered at \(fileName), line \(#line)")

        animateButtonTap(sender)
        delegate?.didSelectMenuOption(.about)
    }

    private func animateButtonTap(_ button: UIButton) {
        UIView.animate(withDuration: 0.1,
                       animations: {
                           button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.1) {
                               button.transform = .identity
                           }
                       })
    }
}
