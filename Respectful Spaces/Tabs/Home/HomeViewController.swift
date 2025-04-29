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
    private var dates = [Date]()

    private var previousMonthButton: UIButton!
    private var nextMonthButton: UIButton!

    private var isSliding = false
    private var slideDirection: CGFloat = 0

    private var selectedIndexPath: IndexPath?
    var selectedDate: Date?
    
    // Configurable circle size - adjust this to change highlight size
    private var dayCircleDiameter: CGFloat = 32


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

    private func setupSegmentedControl() {
        segmentedControl = UISegmentedControl(items: ["Monthly", "Weekly", "Daily"])
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
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let cellWidth = (view.frame.width - 20) / 7
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DateCell.self, forCellWithReuseIdentifier: "dateCell")
        collectionView.backgroundColor = .white

        view.addSubview(collectionView)

        collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 4)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionViewTopConstraint!
        ])
    }

    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        monthLabel.text = dateFormatter.string(from: currentDate)
    }

    private func loadDays() {
        days.removeAll()
        dates.removeAll()

        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let firstDayOfMonth = calendar.date(from: components)!
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)

        for _ in 1..<weekday {
            days.append("")
            dates.append(Date.distantPast) // placeholder
        }

        for day in range {
            days.append("\(day)")
            if let date = calendar.date(bySetting: .day, value: day, of: firstDayOfMonth) {
                dates.append(date)
            }
        }

        collectionView.reloadData()
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

        // Store current state
        let oldDate = currentDate
        let oldMonthText = monthLabel.text ?? ""
        
        // Calculate and set new date
        let newDate = calendar.date(byAdding: .month, value: value, to: currentDate)!
        currentDate = newDate
        
        // Create temporary label for the new month
        let tempMonthLabel = UILabel()
        tempMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        tempMonthLabel.font = monthLabel.font
        tempMonthLabel.textAlignment = .center
        
        // Set up the temporary month label with the new month text
        updateMonthLabel() // This updates the monthLabel's text to the new month
        tempMonthLabel.text = monthLabel.text
        monthLabel.text = oldMonthText // Set back to the old month temporarily
        
        // Create temporary weekday stack view
        let tempWeekdayStackView = UIStackView()
        tempWeekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        tempWeekdayStackView.axis = .horizontal
        tempWeekdayStackView.distribution = .fillEqually
        tempWeekdayStackView.alignment = .center
        
        // Copy weekday labels to temp stack view
        let weekdaySymbols = calendar.shortStandaloneWeekdaySymbols
        for day in weekdaySymbols {
            let label = UILabel()
            label.text = day
            label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            label.textAlignment = .center
            label.textColor = .darkGray
            tempWeekdayStackView.addArrangedSubview(label)
        }
        
        // Create a temporary collection view for the new month
        let tempLayout = UICollectionViewFlowLayout()
        tempLayout.scrollDirection = .vertical
        tempLayout.minimumInteritemSpacing = 0
        tempLayout.minimumLineSpacing = 0
        
        let cellWidth = (view.frame.width - 20) / 7
        tempLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        let tempCollectionView = UICollectionView(frame: collectionView.frame, collectionViewLayout: tempLayout)
        tempCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tempCollectionView.delegate = self
        tempCollectionView.dataSource = self
        tempCollectionView.register(DateCell.self, forCellWithReuseIdentifier: "dateCell")
        tempCollectionView.backgroundColor = .white
        
        // Add all temporary views to the main view
        view.addSubview(tempMonthLabel)
        view.addSubview(tempWeekdayStackView)
        view.insertSubview(tempCollectionView, belowSubview: collectionView)
        
        // Load data for the new month
        loadDays()
        
        // Refresh the temporary collection view with new data
        tempCollectionView.reloadData()
        tempCollectionView.layoutIfNeeded() // Force layout to ensure proper rendering
        
        // Now restore the original date and reload the main collection view
        currentDate = oldDate
        loadDays()
        
        // Position the temporary views for animation
        let slideOffset = view.frame.width * (slideDirection)
        
        NSLayoutConstraint.activate([
            tempMonthLabel.topAnchor.constraint(equalTo: monthLabel.topAnchor),
            tempMonthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tempMonthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            tempWeekdayStackView.topAnchor.constraint(equalTo: weekdayStackView.topAnchor),
            tempWeekdayStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tempWeekdayStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tempWeekdayStackView.heightAnchor.constraint(equalToConstant: 20),
            
            tempCollectionView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            tempCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tempCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tempCollectionView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
        
        // Position the new views off-screen initially
        tempMonthLabel.transform = CGAffineTransform(translationX: slideOffset, y: 0)
        tempWeekdayStackView.transform = CGAffineTransform(translationX: slideOffset, y: 0)
        tempCollectionView.transform = CGAffineTransform(translationX: slideOffset, y: 0)
        
        // Animate the transition
        UIView.animate(withDuration: 0.4, animations: {
            // Slide current views off screen
            self.monthLabel.transform = CGAffineTransform(translationX: -slideOffset, y: 0)
            self.weekdayStackView.transform = CGAffineTransform(translationX: -slideOffset, y: 0)
            self.collectionView.transform = CGAffineTransform(translationX: -slideOffset, y: 0)
            
            // Slide new views onto screen
            tempMonthLabel.transform = .identity
            tempWeekdayStackView.transform = .identity
            tempCollectionView.transform = .identity
        }) { _ in
            // Clean up and update with the new data
            self.monthLabel.transform = .identity
            self.weekdayStackView.transform = .identity
            self.collectionView.transform = .identity
            
            self.currentDate = newDate
            self.updateMonthLabel()
            self.loadDays()
            
            // Remove temporary views
            tempMonthLabel.removeFromSuperview()
            tempWeekdayStackView.removeFromSuperview()
            tempCollectionView.removeFromSuperview()
            
            self.isSliding = false
        }
    }

    @objc private func segmentChanged() {
        UIView.animate(withDuration: 0.3) {
            let show = self.segmentedControl.selectedSegmentIndex == 0
            self.monthLabel.alpha = show ? 1 : 0
            self.collectionView.alpha = show ? 1 : 0
            self.weekdayStackView.alpha = show ? 1 : 0
        }
    }

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
            nextMonth()
        } else if gesture.direction == .right {
            previousMonth()
        }
    }

    // MARK: UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as? DateCell else {
            return UICollectionViewCell()
        }
        
        // Configure cell
        let day = days[indexPath.item]
        let date = dates[indexPath.item]
        let isToday = calendar.isDateInToday(date)
        let isSelected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
        
        cell.configure(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            circleDiameter: dayCircleDiameter
        )
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = dates[indexPath.item]
        guard date != Date.distantPast else { return }
        
        selectedDate = date
        collectionView.reloadData()
    }
}

// Custom cell for calendar dates
class DateCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let todayCircleView = UIView()
    private let selectedCircleView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Add circle views first (so they appear behind the label)
        contentView.addSubview(todayCircleView)
        contentView.addSubview(selectedCircleView)
        
        // Then add label on top
        contentView.addSubview(dayLabel)
        
        // Configure label
        dayLabel.textAlignment = .center
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure circle views
        todayCircleView.translatesAutoresizingMaskIntoConstraints = false
        todayCircleView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        todayCircleView.isHidden = true
        todayCircleView.layer.masksToBounds = true
        
        selectedCircleView.translatesAutoresizingMaskIntoConstraints = false
        selectedCircleView.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
        selectedCircleView.isHidden = true
        selectedCircleView.layer.masksToBounds = true
        
        // Center the label
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(day: String, isToday: Bool, isSelected: Bool, circleDiameter: CGFloat) {
        dayLabel.text = day
        
        // Remove any existing constraints for circles
        for view in [todayCircleView, selectedCircleView] {
            for constraint in view.constraints {
                view.removeConstraint(constraint)
            }
            for constraint in contentView.constraints where constraint.firstItem === view || constraint.secondItem === view {
                contentView.removeConstraint(constraint)
            }
        }
        
        // Set circle size and center them
        for view in [todayCircleView, selectedCircleView] {
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: circleDiameter),
                view.heightAnchor.constraint(equalToConstant: circleDiameter),
                view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
            view.layer.cornerRadius = circleDiameter / 2
        }
        
        // Show/hide circles based on state
        todayCircleView.isHidden = !isToday
        selectedCircleView.isHidden = !isSelected || isToday // Today's highlight takes precedence
        
        // Ensure the label is above the circles
        contentView.bringSubviewToFront(dayLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = ""
        todayCircleView.isHidden = true
        selectedCircleView.isHidden = true
    }
}
