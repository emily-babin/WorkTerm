import UIKit

class UpcomingEventsDrawerViewController: UIViewController {
    
    // MARK: - Views
    private let upcomingEventsScrollView = UIScrollView()
    private let upcomingEventsStack = UIStackView()
    private let grabber = UIView()
    
    // Drawer constraint (we'll animate this)
    private var drawerTopConstraint: NSLayoutConstraint!
    
    // Height Constants
    private let closedHeight: CGFloat = -150
    private let openHeight: CGFloat = -400

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDrawer()
    }

    private func setupDrawer() {
        view.backgroundColor = .clear

        // Scroll View Setup
        upcomingEventsScrollView.translatesAutoresizingMaskIntoConstraints = false
        upcomingEventsScrollView.backgroundColor = .systemBackground
        upcomingEventsScrollView.layer.cornerRadius = 16
        upcomingEventsScrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        upcomingEventsScrollView.clipsToBounds = true
        view.addSubview(upcomingEventsScrollView)

        // Stack View Setup
        upcomingEventsStack.axis = .vertical
        upcomingEventsStack.spacing = 8
        upcomingEventsStack.translatesAutoresizingMaskIntoConstraints = false
        upcomingEventsScrollView.addSubview(upcomingEventsStack)

        // Grabber View
        grabber.backgroundColor = .systemGray2
        grabber.layer.cornerRadius = 3
        grabber.translatesAutoresizingMaskIntoConstraints = false
        upcomingEventsScrollView.addSubview(grabber)

        // Pan Gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawerPan(_:)))
        upcomingEventsScrollView.addGestureRecognizer(panGesture)

        // Constraints
        drawerTopConstraint = upcomingEventsScrollView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: closedHeight)

        NSLayoutConstraint.activate([
            drawerTopConstraint,
            upcomingEventsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upcomingEventsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upcomingEventsScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            grabber.topAnchor.constraint(equalTo: upcomingEventsScrollView.topAnchor, constant: 8),
            grabber.centerXAnchor.constraint(equalTo: upcomingEventsScrollView.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 40),
            grabber.heightAnchor.constraint(equalToConstant: 6),

            upcomingEventsStack.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 16),
            upcomingEventsStack.leadingAnchor.constraint(equalTo: upcomingEventsScrollView.leadingAnchor),
            upcomingEventsStack.trailingAnchor.constraint(equalTo: upcomingEventsScrollView.trailingAnchor),
            upcomingEventsStack.bottomAnchor.constraint(equalTo: upcomingEventsScrollView.bottomAnchor),
            upcomingEventsStack.widthAnchor.constraint(equalTo: upcomingEventsScrollView.widthAnchor)
        ])

        // Example content (you can remove this)
        for i in 1...5 {
            let label = UILabel()
            label.text = "Event \(i)"
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .center
            label.backgroundColor = .systemRed.withAlphaComponent(0.1)
            label.layer.cornerRadius = 8
            label.clipsToBounds = true
            upcomingEventsStack.addArrangedSubview(label)
        }
    }

    // MARK: - Pan Handler
    @objc private func handleDrawerPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .changed:
            let newConstant = drawerTopConstraint.constant + translation.y
            if newConstant >= openHeight && newConstant <= closedHeight {
                drawerTopConstraint.constant = newConstant
                gesture.setTranslation(.zero, in: view)
            }

        case .ended:
            let shouldOpen = velocity.y < 0
            let targetConstant: CGFloat = shouldOpen ? openHeight : closedHeight

            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                self.drawerTopConstraint.constant = targetConstant
                self.view.layoutIfNeeded()
            }

        default:
            break
        }
    }
}
