import UIKit

class CustomHeaderView: UIView {
    
    // MARK: - UI Elements
    let menuButton = UIButton(type: .system)
    let titleLabel = UILabel()
    let logoImageView = UIImageView()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .systemRed
        // Menu Button
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .white
        
        // Title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        
        // Logo Image
        logoImageView.image = UIImage(systemName: "hexagon.fill")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .systemYellow
        
        // Order of Items in Header
        let headerStack = UIStackView(arrangedSubviews: [menuButton, titleLabel, logoImageView])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalCentering
        headerStack.alignment = .center
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(headerStack)
        
        // Constraints
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: topAnchor),
            headerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Public Methods
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setMenuButtonAction(_ target: Any?, action: Selector) {
        menuButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
