//
//  BaseViewController.swift
//  Respectful Spaces
//
//  Created by Emily Babin on 2025-04-25.
//
//  This class serves as a base view controller for all main screens.
//  It contains the shared UI components: a custom header bar with a side menu
//  Main classes can inherit this to keep a consistent layout
//

import UIKit

class BaseViewController: UIViewController, CustomHeaderViewDelegate, SideMenuDelegate {
    
    private var headerView: CustomHeaderView!
    private var dimmingView: UIView!
    private var sideMenu: SideMenuView!
    private var isMenuVisible = false

    var screenTitle: String {
        return "Title"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeader()
        setupSideMenu()
    }

    // MARK: Header
    private func setupHeader() {
        headerView = CustomHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerView.titleText = screenTitle
        headerView.delegate = self

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: Side Menu
    private func setupSideMenu() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        dimmingView.addGestureRecognizer(tapGesture)

        sideMenu = SideMenuView()
        sideMenu.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideMenu)

        NSLayoutConstraint.activate([
            sideMenu.topAnchor.constraint(equalTo: view.topAnchor),
            sideMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -250),
            sideMenu.widthAnchor.constraint(equalToConstant: 250)
        ])

        sideMenu.delegate = self
    }

    func didTapMenuButton() {
        toggleMenu()
    }

    private func toggleMenu() {
        isMenuVisible.toggle()
        view.bringSubviewToFront(dimmingView)
        view.bringSubviewToFront(sideMenu)

        UIView.animate(withDuration: 0.3) {
            self.sideMenu.transform = self.isMenuVisible
                ? CGAffineTransform(translationX: 250, y: 0)
                : .identity
            self.dimmingView.alpha = self.isMenuVisible ? 1 : 0
        }
    }

    @objc private func dismissMenu() {
        if isMenuVisible {
            toggleMenu()
        }
    }

    func didSelectMenuOption(_ option: SideMenuOption) {
        switch option {
        case .settings:
            performSegue(withIdentifier: "showSettings", sender: self)
        case .about:
            performSegue(withIdentifier: "showAbout", sender: self)
        }
    }
}
