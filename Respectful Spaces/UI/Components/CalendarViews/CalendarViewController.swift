import UIKit

// MARK: - CalendarViewControllerDelegate
protocol CalendarViewControllerDelegate: AnyObject {
    func calendarViewController(_ controller: CalendarViewController, didSelectDate date: Date)
}

// MARK: - CalendarViewController
class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: - Properties
    private var monthLabel: UILabel!
    private var weekdayStackView: UIStackView!
    private var collectionView: UICollectionView!
    private var collectionViewTopConstraint: NSLayoutConstraint?
    
    private var previousMonthButton: UIButton!
    private var nextMonthButton: UIButton!
    
    private let calendar = Calendar.current
    private var currentDate = Date()
    private var days = [String]()
    private var dates = [Date]()
    private var isCurrentMonth = [Bool]() // Tracks if a day belongs to current month
    
    private var isSliding = false
    private var slideDirection: CGFloat = 0
    
    private var selectedDate: Date?
    
    // MARK: - Configurable Properties
    private var dayCircleDiameter: CGFloat = 32
    private var calendarHeight: CGFloat = 250
    
    // MARK: - Delegate
    weak var delegate: CalendarViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        loadDays()
        setupSwipeGestures()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupMonthLabel()
        setupWeekdayHeaders()
        setupNavigationButtons()
        setupCollectionView()
    }
    
    private func setupMonthLabel() {
        monthLabel = UILabel()
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        monthLabel.textAlignment = .center
        updateMonthLabel()
        view.addSubview(monthLabel)
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: view.topAnchor),
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
    
    // MARK: - Calendar Data
    private func updateMonthLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        monthLabel.text = dateFormatter.string(from: currentDate)
    }
    
    private func loadDays() {
        days.removeAll()
        dates.removeAll()
        isCurrentMonth.removeAll()
        
        // Get calendar dates for the current month
        let calendarDates = generateCalendarDates(for: currentDate)
        
        // Process each date
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        let currentMonth = components.month
        let currentYear = components.year
        
        for date in calendarDates {
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let isInCurrentMonth = dateComponents.month == currentMonth && dateComponents.year == currentYear
            
            // Add the date information
            days.append("\(dateComponents.day!)")
            dates.append(date)
            isCurrentMonth.append(isInCurrentMonth)
        }
        
        collectionView.reloadData()
    }
    
    func generateCalendarDates(for month: Date) -> [Date] {
        var calendar = Calendar.current
        calendar.firstWeekday = 1 // 1 = Sunday, adjust as needed
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        
        let firstDayWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysOffset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        // Get the first day of the calendar (which might be from the previous month)
        let firstCalendarDate = calendar.date(byAdding: .day, value: -daysOffset, to: startOfMonth)!
        
        // Generate all 42 days (6 weeks)
        var dates = [Date]()
        for day in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: day, to: firstCalendarDate) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    // MARK: - Navigation
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
    
    // MARK: - Gesture Handling
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
    
    // MARK: - UICollectionView DataSource
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
        let belongsToCurrentMonth = isCurrentMonth[indexPath.item]
        
        // Note: We've removed the isSelected parameter as requested
        cell.configure(
            day: day,
            isToday: isToday,
            circleDiameter: dayCircleDiameter,
            isCurrentMonth: belongsToCurrentMonth
        )
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = dates[indexPath.item]
        selectedDate = date
        
        // Notify delegate about the selection
        delegate?.calendarViewController(self, didSelectDate: date)
    }
}

// MARK: - DateCell
class DateCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let todayCircleView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Add circle view first (so it appears behind the label)
        contentView.addSubview(todayCircleView)
        
        // Then add label on top
        contentView.addSubview(dayLabel)
        
        // Configure label
        dayLabel.textAlignment = .center
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure circle view
        todayCircleView.translatesAutoresizingMaskIntoConstraints = false
        todayCircleView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        todayCircleView.isHidden = true
        todayCircleView.layer.masksToBounds = true
        
        // Center the label
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(day: String, isToday: Bool, circleDiameter: CGFloat, isCurrentMonth: Bool = true) {
        dayLabel.text = day
        
        // Apply proper text color based on whether the date is in the current month
        dayLabel.textColor = isCurrentMonth ? .black : .lightGray
        
        // Remove any existing constraints for circle
        for constraint in todayCircleView.constraints {
            todayCircleView.removeConstraint(constraint)
        }
        for constraint in contentView.constraints where constraint.firstItem === todayCircleView || constraint.secondItem === todayCircleView {
            contentView.removeConstraint(constraint)
        }
        
        // Set circle size and center it
        NSLayoutConstraint.activate([
            todayCircleView.widthAnchor.constraint(equalToConstant: circleDiameter),
            todayCircleView.heightAnchor.constraint(equalToConstant: circleDiameter),
            todayCircleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            todayCircleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        todayCircleView.layer.cornerRadius = circleDiameter / 2
        
        // Show/hide circle based on state
        todayCircleView.isHidden = !isToday
        
        // Ensure the label is above the circle
        contentView.bringSubviewToFront(dayLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = ""
        dayLabel.textColor = .black
        todayCircleView.isHidden = true
    }
}
