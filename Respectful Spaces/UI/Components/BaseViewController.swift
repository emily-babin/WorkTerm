import UIKit

class BaseViewController: UIViewController, CustomHeaderViewDelegate, SideMenuDelegate {

    private var headerView: CustomHeaderView!
    private var sideMenu: SideMenuView!
    private var dimmingView: UIView!
    var isMenuVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView()
        setupSideMenu()
        setupDimmingView()
}
 
    private func setupHeaderView() {
        headerView = CustomHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.delegate = self
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupSideMenu() {
        sideMenu = SideMenuView()
        sideMenu.delegate = self
        sideMenu.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideMenu)

        NSLayoutConstraint.activate([
            sideMenu.topAnchor.constraint(equalTo: view.topAnchor),
            sideMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -250),
            sideMenu.widthAnchor.constraint(equalToConstant: 250)
        ])
    }

    private func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.alpha = 0
        dimmingView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleMenu))
        dimmingView.addGestureRecognizer(tap)
        view.insertSubview(dimmingView, belowSubview: sideMenu)

        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func setHeaderTitle(_ title: String) {
        headerView.titleText = title
    }

    @objc func toggleMenu() {
        isMenuVisible.toggle()

        let sideMenuX = isMenuVisible ? 0 : -250
        UIView.animate(withDuration: 0.3) {
            self.sideMenu.frame.origin.x = CGFloat(sideMenuX)
            self.dimmingView.alpha = self.isMenuVisible ? 1 : 0
        }
    }

    // MARK: - Header Delegate
    func didTapMenuButton() {
        toggleMenu()
    }

    // MARK: - Side Menu Delegate
    func didSelectMenuOption(_ option: SideMenuOption) {
        print("Tapped option: \(option)")
        let fileName = (NSString(string: #file).lastPathComponent)
        print("Triggered at \(fileName), line \(#line)")

//        toggleMenu() // hide the menu first

        switch option {
        case .settings:
            performSegue(withIdentifier: "showSettings", sender: self)
        case .about:
            performSegue(withIdentifier: "showAbout", sender: self)
        }
    }

    // This method will be called in subclasses like HomeViewController
    func handleMenuOption(_ option: SideMenuOption) {
        // This method can be overridden in subclasses to handle menu options
        print("handleMenuOption in BaseViewController - Option: \(option)")
        let fileName = (NSString(string: #file).lastPathComponent)
        print("Triggered at \(fileName), line \(#line)")

    }
}
