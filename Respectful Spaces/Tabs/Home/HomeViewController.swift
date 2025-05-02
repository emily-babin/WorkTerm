import UIKit
import FirebaseFirestore

class HomeViewController: BaseViewController, CalendarViewControllerDelegate {
    // DB
    let db = Firestore.firestore()
    
    // MARK: - UI Elements
    let segmentedControl = UISegmentedControl(items: ["Monthly", "Weekly", "Daily"])
    let calendarContainer = UIView()
    
    // Calendar View Controllers
    private var monthlyCalendarViewController: CalendarViewController!
    let weeklyCalendarView = UIView() // Placeholder for now
    let dailyCalendarView = UIView() // Placeholder for now

    // Upcoming Section
    let upcomingHeaderView = UIView()
    let upcomingLabel = UILabel()
    let upcomingEventsScrollView = UIScrollView()
    let upcomingEventsStack = UIStackView()
    
    // Date selection
    private var selectedDate: Date = Date()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setScreenTitle("Calendar")
        setupSegmentedControl()
        setupCalendarContainer()
        setupMonthlyCalendar()
        setupUpcomingEventsSection()
        layoutViews()
        showCalendar(type: .monthly)
        
        // Initialize with placeholder event data
        loadPlaceholderEvents()
    }

    // MARK: - Setup Methods

    // Segmented Control
    func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(calendarTypeChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
    }

    // Calendar
    func setupCalendarContainer() {
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarContainer)
        
        // Only setup placeholders for weekly and daily views
        weeklyCalendarView.backgroundColor = .systemGray6
        dailyCalendarView.backgroundColor = .systemGray6

        [weeklyCalendarView, dailyCalendarView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            calendarContainer.addSubview($0)
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
                $0.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor),
                $0.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor)
            ])
        }
    }
    
    func setupMonthlyCalendar() {
        // Initialize the monthly calendar view controller
        monthlyCalendarViewController = CalendarViewController()
        monthlyCalendarViewController.delegate = self
        
        // Add as a child view controller
        addChild(monthlyCalendarViewController)
        calendarContainer.addSubview(monthlyCalendarViewController.view)
        monthlyCalendarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthlyCalendarViewController.view.topAnchor.constraint(equalTo: calendarContainer.topAnchor),
            monthlyCalendarViewController.view.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor),
            monthlyCalendarViewController.view.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor),
            monthlyCalendarViewController.view.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor)
        ])
        
        monthlyCalendarViewController.didMove(toParent: self)
    }

    func setupUpcomingEventsSection() {
        // Header Container
        upcomingHeaderView.backgroundColor = .systemGray6
        upcomingHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upcomingHeaderView)

        // Label inside the header
        upcomingLabel.text = "UPCOMING"
        upcomingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        upcomingLabel.translatesAutoresizingMaskIntoConstraints = false
        upcomingHeaderView.addSubview(upcomingLabel)

        // ScrollView and StackView
        upcomingEventsScrollView.translatesAutoresizingMaskIntoConstraints = false
        upcomingEventsStack.axis = .vertical
        upcomingEventsStack.spacing = 8
        upcomingEventsStack.translatesAutoresizingMaskIntoConstraints = false

        upcomingEventsScrollView.addSubview(upcomingEventsStack)
        view.addSubview(upcomingEventsScrollView)

        // Constraints for header and label
        NSLayoutConstraint.activate([
            upcomingHeaderView.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 20),
            upcomingHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            upcomingHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            upcomingHeaderView.heightAnchor.constraint(equalToConstant: 40),

            upcomingLabel.centerYAnchor.constraint(equalTo: upcomingHeaderView.centerYAnchor),
            upcomingLabel.leadingAnchor.constraint(equalTo: upcomingHeaderView.leadingAnchor, constant: 16),

            upcomingEventsScrollView.topAnchor.constraint(equalTo: upcomingHeaderView.bottomAnchor, constant: 8),
            upcomingEventsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            upcomingEventsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            upcomingEventsScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            upcomingEventsStack.topAnchor.constraint(equalTo: upcomingEventsScrollView.topAnchor),
            upcomingEventsStack.bottomAnchor.constraint(equalTo: upcomingEventsScrollView.bottomAnchor),
            upcomingEventsStack.leadingAnchor.constraint(equalTo: upcomingEventsScrollView.leadingAnchor),
            upcomingEventsStack.trailingAnchor.constraint(equalTo: upcomingEventsScrollView.trailingAnchor),
            upcomingEventsStack.widthAnchor.constraint(equalTo: upcomingEventsScrollView.widthAnchor)
        ])
    }


    func layoutViews() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            calendarContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            calendarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarContainer.heightAnchor.constraint(equalToConstant: 380),

            upcomingLabel.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: 20),
            upcomingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            upcomingEventsScrollView.topAnchor.constraint(equalTo: upcomingLabel.bottomAnchor, constant: 8),
            upcomingEventsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            upcomingEventsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            upcomingEventsScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Calendar Switching

    enum CalendarType {
        case monthly, weekly, daily
    }

    func showCalendar(type: CalendarType) {
        monthlyCalendarViewController.view.isHidden = type != .monthly
        weeklyCalendarView.isHidden = type != .weekly
        dailyCalendarView.isHidden = type != .daily
    }

    @objc func calendarTypeChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: showCalendar(type: .monthly)
        case 1: showCalendar(type: .weekly)
        case 2: showCalendar(type: .daily)
        default: break
        }
    }
    
    // MARK: - CalendarViewControllerDelegate
    
    func calendarViewController(_ controller: CalendarViewController, didSelectDate date: Date) {
        // Store the selected date
        self.selectedDate = date
        
        // Update upcoming events based on the selected date
        updateUpcomingEvents(for: date)
    }
    
    // MARK: - Event Management
    
    // This is a placeholder function that would be replaced with real data fetching
    func loadPlaceholderEvents() {
        // Clear existing event cards
        upcomingEventsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create example event cards
        for i in 1...5 {
            let eventCard = createEventCard(title: "Event \(i)", time: "10:00 AM", location: "Location \(i)")
            upcomingEventsStack.addArrangedSubview(eventCard)
        }
    }
    
    func updateUpcomingEvents(for date: Date) {
        // Clear existing event cards
        upcomingEventsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Format the date for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: date)
        
        // In a real app, you would filter events for the selected date
        // For now, create some placeholder cards with the selected date
        let eventCard = createEventCard(
            title: "Selected Date Events",
            time: "All Day",
            location: "Events for \(dateString)"
        )
        upcomingEventsStack.addArrangedSubview(eventCard)
        
        // Add a few more random events
        for i in 1...3 {
            let hour = 8 + i * 2
            let eventCard = createEventCard(
                title: "Meeting \(i)",
                time: "\(hour):00 AM",
                location: "Conference Room \(i)"
            )
            upcomingEventsStack.addArrangedSubview(eventCard)
        }
    }
    
    func createEventCard(title: String, time: String, location: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .secondarySystemBackground
        card.layer.cornerRadius = 10
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Time label
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .systemBlue
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Location label
        let locationLabel = UILabel()
        locationLabel.text = location
        locationLabel.font = UIFont.systemFont(ofSize: 14)
        locationLabel.textColor = .secondaryLabel
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add all labels to the card
        card.addSubview(titleLabel)
        card.addSubview(timeLabel)
        card.addSubview(locationLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 8),
            locationLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -16)
        ])
        
        return card
    }
}
