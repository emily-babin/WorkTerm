import UIKit

class BaseViewController: UIViewController, SideMenuDelegate {
    
    // MARK: - UI Elements
    let headerView = CustomHeaderView()
    private var sideMenuView: SideMenuView?
    private var sideMenuLeadingConstraint: NSLayoutConstraint?
    private var dimView: UIView?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupSideMenu()
    }
    
    // MARK: - Setup Methods
    func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // Set menu button action
        headerView.setMenuButtonAction(self, action: #selector(menuButtonTapped))
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSideMenu() {
        // Create side menu
        let menuWidth = view.bounds.width * 0.7 // 70% of screen width
        sideMenuView = SideMenuView(frame: CGRect(x: 0, y: 0, width: menuWidth, height: view.bounds.height))
        
        if let sideMenuView = sideMenuView {
            sideMenuView.delegate = self
            sideMenuView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create dim view (background overlay when menu is open)
            dimView = UIView()
            if let dimView = dimView {
                dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                dimView.alpha = 0
                dimView.translatesAutoresizingMaskIntoConstraints = false
                
                // Add tap gesture to dismiss menu when tapping outside
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSideMenu))
                dimView.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    // Add the side menu to the view hierarchy when needed
    private func ensureSideMenuInViewHierarchy() {
        // Only add the views if they're not already in the hierarchy
        if let dimView = dimView, dimView.superview == nil {
            // Add dim view as the topmost layer
            view.addSubview(dimView)
            
            NSLayoutConstraint.activate([
                dimView.topAnchor.constraint(equalTo: view.topAnchor),
                dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        if let sideMenuView = sideMenuView, sideMenuView.superview == nil {
            // Add side menu as the very topmost layer (above dim view)
            view.addSubview(sideMenuView)
            
            // Set initial position (off-screen)
            let menuWidth = sideMenuView.frame.width
            sideMenuLeadingConstraint = sideMenuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -menuWidth)
            
            NSLayoutConstraint.activate([
                sideMenuLeadingConstraint!,
                sideMenuView.topAnchor.constraint(equalTo: view.topAnchor),
                sideMenuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                sideMenuView.widthAnchor.constraint(equalToConstant: menuWidth)
            ])
        }
    }
    
    // Helper method to set the screen title
    func setScreenTitle(_ title: String) {
        headerView.setTitle(title)
    }
    
    // MARK: - Side Menu Actions
    @objc func menuButtonTapped() {
        // Make sure we bring the menu to the front every time
        if let dimView = dimView {
            view.bringSubviewToFront(dimView)
        }
        if let sideMenuView = sideMenuView {
            view.bringSubviewToFront(sideMenuView)
        }
        toggleSideMenu()
    }
    
    @objc func dismissSideMenu() {
        hideSideMenu()
    }
    
    private func toggleSideMenu() {
        // Ensure the menu is in the view hierarchy and on top
        ensureSideMenuInViewHierarchy()
        
        guard let constraint = sideMenuLeadingConstraint else { return }
        
        let menuIsHidden = constraint.constant < 0
        
        if menuIsHidden {
            // Show menu
            UIView.animate(withDuration: 0.3) {
                constraint.constant = 0
                self.dimView?.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else {
            // Hide menu
            hideSideMenu()
        }
    }
    
    private func hideSideMenu() {
        guard let sideMenuView = sideMenuView, let constraint = sideMenuLeadingConstraint else { return }
        
        UIView.animate(withDuration: 0.3) {
            constraint.constant = -sideMenuView.bounds.width
            self.dimView?.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - SideMenuDelegate
    func didSelectMenuOption(_ option: SideMenuOption) {
        hideSideMenu()
        
        switch option {
            case .settings:
                handleSettingsOption()
            case .about:
                handleAboutOption()
        }
    }
    
    // These methods can be overridden by subclasses to handle specific menu options
    func handleSettingsOption() {
        print("Settings selected")
        performSegue(withIdentifier: "showSettings", sender: self)
    }
    
    func handleAboutOption() {
        print("About selected")
        performSegue(withIdentifier: "showAbout", sender: self)
    }
}
