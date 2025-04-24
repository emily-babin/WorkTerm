//
//  HomeViewController.swift
//  Respectful Spaces
//
//  Created by Babin,Emily on 2025-04-24.
//
//
import UIKit

class ToolboxViewController: UIViewController, CustomHeaderViewDelegate, SideMenuDelegate {
    
    private var dimmingView: UIView!
    private var sideMenu: SideMenuView!
    private var isMenuVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Header Bar
        let headerView = CustomHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        headerView.titleText = "Toolbox"
        headerView.delegate = self
        
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        setupSideMenu()
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


    // Drawer Menu
    private func setupSideMenu() {
        // Create and add the dimming view
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

        // Add tap gesture to dismiss menu
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        dimmingView.addGestureRecognizer(tapGesture)

        // Now add the side menu *on top* of the dimming view
        sideMenu = SideMenuView()
        sideMenu.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(sideMenu)

        NSLayoutConstraint.activate([
            sideMenu.topAnchor.constraint(equalTo: view.topAnchor),
            sideMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -250),
            sideMenu.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    @objc private func dismissMenu() {
        if isMenuVisible {
            toggleMenu()
        }
    }
    
    func didSelectMenuOption(_ option: SideMenuOption) {
//        dismissMenu()
        switch option {
        case .settings:
            performSegue(withIdentifier: "showSettings", sender: self)
        case .about:
            performSegue(withIdentifier: "showAbout", sender: self)
        }
    }
        
}

