//
//  SideMenuView.swift
//  Respectful Spaces
//
//  Created by Babin,Emily on 2025-04-24.
//
//  Controls the side menu that pops up on clicking the menu button
//  in the header bar and the items that are in it

import UIKit

protocol SideMenuDelegate: AnyObject {
    func didSelectMenuOption(_ option: SideMenuOption)
}

enum SideMenuOption {
    case settings
    case about
    
    // TEMPORARY
    case calendar
}

// MARK: - Side Menu
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

    // Menu UI Setup
    private func setupView() {
        backgroundColor = .systemGray6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 3, height: 0)
        layer.shadowRadius = 6

        let settingsButton = createMenuButton(title: "Settings", systemImage: "gearshape", option: .settings)

        let aboutButton = createMenuButton(title: "About",systemImage: "info.circle", option: .about)
        // TEMPORARY
        let calendarButton = createMenuButton(title: "Calendar", systemImage: "calendar", option: .calendar)
        
        let stackView = UIStackView(arrangedSubviews: [settingsButton, aboutButton, calendarButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 100)
        ])
    }

    // One function to create every button, just requires a title, image and the option
    private func createMenuButton(title: String, systemImage: String, option: SideMenuOption) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = title
        config.image = UIImage(systemName: systemImage)
        config.imagePadding = 10
        config.baseForegroundColor = .label
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        button.configuration = config
        button.contentHorizontalAlignment = .leading

        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.animateButtonTap(button)
            self.delegate?.didSelectMenuOption(option)
        }, for: .touchUpInside)

        return button
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
