import UIKit

class HomeViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    override var screenTitle: String { return "Home" }
    
    private var segmentedControl: UISegmentedControl!
    private var monthLabel: UILabel!
    private var weekdayStackView: UIStackView!
    private var collectionView: UICollectionView!
    private var collectionViewTopConstraint: NSLayoutConstraint?
    
    private let calendar = Calendar.current
    private var currentDate = Date()
    private var days = [String]()
    
    private var previousMonthButton: UIButton!
    private var nextMonthButton: UIButton!
    
    private var isSliding = false
    private var slideDirection: CGFloat = 0  // Positive for next month, negative for previous month
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSegmentedControl()
        setupMonthLabel()
        setupWeekdayHeaders()
        setupNavigationButtons()
        setupCollectionView()
        loadDays()
        setupSwipeGestures()
    }
    
    // MARK: - Setup UI
    
    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Month", "Weekly", "Day"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupMonthLabel() {
        monthLabel = UILabel()
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        monthLabel.textAlignment = .center
        updateMonthLabel()
        view.addSubview(monthLabel)
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            monthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            monthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupWeekdayHeaders() {
        let weekdaySymbols = calendar.shortStandaloneWeekdaySymbols
        
        weekdayStackView = UIStackView()
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        weekdayStackView.axis = .horizontal
        weekdayStackView.distribution = .fillEqually
        weekdayStackView.alignment = .center
        weekdayStackView.spacing = 0
        
        for day in weekdaySymbols {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .darkGray
            weekdayStackView.addArrangedSubview(label)
        }
        
        view.addSubview(weekdayStackView)
        
        NSLayoutConstraint.activate([
            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            weekdayStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            weekdayStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupNavigationButtons() {
        previousMonthButton = UIButton(type: .system)
        previousMonthButton.setTitle("<", for: .normal)
        previousMonthButton.translatesAutoresizingMaskIntoConstraints = false
        previousMonthButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        view.addSubview(previousMonthButton)
        
        nextMonthButton = UIButton(type: .system)
        nextMonthButton.setTitle(">", for: .normal)
        nextMonthButton.translatesAutoresizingMaskIntoConstraints = false
        nextMonthButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        view.addSubview(nextMonthButton)
        
        NSLayoutConstraint.activate([
            previousMonthButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            previousMonthButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            nextMonthButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let width = (view.frame.width - 20) / 7
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        
        view.addSubview(collectionView)
        
        collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 4)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionViewTopConstraint!
        ])
    }
    
    // MARK: - Load Data
    
    private func loadDays() {
        days.removeAll()
        
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let firstDayOfMonth = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        for _ in 1..<weekday {
            days.append("")
        }
        
        for day in range {
            days.append("\(day)")
        }
        
        collectionView.reloadData()
    }
    
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        monthLabel.text = dateFormatter.string(from: currentDate)
    }
    
    // MARK: - Segmented Control Action
    
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:  // "Month" selected
            // Show month label and collection view (calendar)
            UIView.animate(withDuration: 0.3) {
                self.monthLabel.alpha = 1
                self.collectionView.alpha = 1
                self.weekdayStackView.alpha = 1
            }
        case 1:  // "Week" selected
            // Hide month label and collection view (calendar)
            UIView.animate(withDuration: 0.3) {
                self.monthLabel.alpha = 0
                self.collectionView.alpha = 0
                self.weekdayStackView.alpha = 0
            }
        case 2:  // "Day" selected
            // Hide month label and collection view (calendar)
            UIView.animate(withDuration: 0.3) {
                self.monthLabel.alpha = 0
                self.collectionView.alpha = 0
                self.weekdayStackView.alpha = 0
            }
        default:
            break
        }
    }

    
    // MARK: - Swipe Gestures
    
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        collectionView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        collectionView.addGestureRecognizer(swipeRight)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            changeMonth(by: 1)
        } else if gesture.direction == .right {
            changeMonth(by: -1)
        }
    }
    
    @objc private func previousMonth() {
        changeMonth(by: -1)
    }
    
    @objc private func nextMonth() {
        changeMonth(by: 1)
    }
    
    private func changeMonth(by value: Int) {
        if isSliding { return }
        
        isSliding = true
        slideDirection = value > 0 ? 1 : -1
        
        let newDate = calendar.date(byAdding: .month, value: value, to: currentDate)!
        
        // Prepare for sliding animation
        let slideOffset: CGFloat = slideDirection * view.frame.width
        
        // Apply the slide transformation to all elements (monthLabel, collectionView, weekdayStackView)
        monthLabel.transform = CGAffineTransform(translationX: slideOffset, y: 0)
        collectionView.transform = CGAffineTransform(translationX: slideOffset, y: 0)
        weekdayStackView.transform = CGAffineTransform(translationX: slideOffset, y: 0)
        
        // Animate the transition
        UIView.animate(withDuration: 0.5, animations: {
            // Slide all elements back to their original positions
            self.monthLabel.transform = .identity
            self.collectionView.transform = .identity
            self.weekdayStackView.transform = .identity
        }) { _ in
            // Once the animation is complete, update the data and state
            self.currentDate = newDate
            self.updateMonthLabel()
            self.loadDays()
            
            // Reset the transform to avoid any accumulation of previous transforms
            self.monthLabel.transform = .identity
            self.collectionView.transform = .identity
            self.weekdayStackView.transform = .identity
            
            self.isSliding = false
        }
    }



    
    // MARK: - UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // Remove old labels
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let label = UILabel(frame: cell.bounds)
        label.textAlignment = .center
        label.text = days[indexPath.item]
        label.font = UIFont.systemFont(ofSize: 16)
        cell.contentView.addSubview(label)
        
        return cell
    }
}
