import UIKit
import FirebaseFirestore

class HomeViewController: BaseViewController, CalendarViewControllerDelegate {
    // DB
    let db = Firestore.firestore()
    
    // Event List
    var listEventAll: [Event] = []
    
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
        
        Task {
            await loadData()
        }
        
        
//        // Initialize with placeholder event data
//        loadPlaceholderEvents()
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
    
    
    // Monthly Calendar - I'd like to move this into it's own ViewController
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
        upcomingHeaderView.backgroundColor = .systemRed
        upcomingHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upcomingHeaderView)

        // Label inside the header
        upcomingLabel.text = "UPCOMING"
        upcomingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        upcomingLabel.translatesAutoresizingMaskIntoConstraints = false
        upcomingHeaderView.addSubview(upcomingLabel)
        upcomingLabel.textColor = .white

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
    func loadData() async {
        do {
            let snapshot = try await db.collection("Events").getDocuments()
            listEventAll.removeAll()

            for document in snapshot.documents {
                guard let array = document.get("array") as? [Timestamp],
                      let timestamp = array.first,
                      let name = document.get("name") as? String else {
                    print("❌ Missing or malformed data in document \(document.documentID)")
                    continue
                }

                let date = timestamp.dateValue()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)

                guard
                      let month = components.month,
                      let day = components.day else {
                    continue
                }

                let event = Event(day: day, month: month, name: name)
                listEventAll.append(event)
            }

            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.updateUpcomingEvents(for: Date()) // Or pass in selected date
            }

        } catch {
            print("Error getting documents: \(error)")
        }
    }

    
    // This is a placeholder function that would be replaced with real data fetching
    func loadPlaceholderEvents() {
        // Clear existing event cards
        upcomingEventsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Create example event cards
//        for i in 1...5 {
//            let eventCard = createEventCard(title: "Event \(i)", time: "10:00 AM", location: "Location \(i)")
//            upcomingEventsStack.addArrangedSubview(eventCard)
//        }
    }
    
    func updateUpcomingEvents(for date: Date) {
        upcomingEventsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Sort events by date if needed (optional but recommended)
//        let calendar = Calendar.current
//        let todayComponents = calendar.dateComponents([.month, .day], from: Date())

        let sortedEvents = listEventAll.sorted {
            if $0.month == $1.month {
                return $0.day < $1.day
            }
            return $0.month < $1.month
        }

        var hasUpcoming = false

        for event in sortedEvents {
            // Optional: only show future events
//            if event.month > todayComponents.month! ||
//                (event.month == todayComponents.month! && event.day >= todayComponents.day!) {
                let card = createEventCard(day: event.day, month: event.month, name: event.name)
                upcomingEventsStack.addArrangedSubview(card)
                hasUpcoming = true
//            }
        }

        if !hasUpcoming {
            let label = UILabel()
            label.text = "No upcoming events."
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            upcomingEventsStack.addArrangedSubview(label)
        }
    }


    func createEventCard(day: Int, month: Int, name: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .clear
        card.translatesAutoresizingMaskIntoConstraints = false
        
        // Container with shadow
        let container = UIView()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(container)
        
        // Left view (month + day)
        let leftView = UIView()
        leftView.backgroundColor = UIColor.systemYellow
        leftView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        leftView.layer.cornerRadius = 12
        leftView.translatesAutoresizingMaskIntoConstraints = false
        
        let dateFormatter = DateFormatter()
        let fullMonth = dateFormatter.monthSymbols[month - 1].uppercased()
        
        let monthLabel = UILabel()
        monthLabel.text = fullMonth
        monthLabel.font = UIFont.boldSystemFont(ofSize: 14)
        monthLabel.textColor = .white
        monthLabel.textAlignment = .center
        
        let dayLabel = UILabel()
        dayLabel.text = "\(day)"
        dayLabel.font = UIFont.boldSystemFont(ofSize: 18)
        dayLabel.textColor = .white
        dayLabel.textAlignment = .center
        
        let dateStack = UIStackView(arrangedSubviews: [monthLabel, dayLabel])
        dateStack.axis = .vertical
        dateStack.alignment = .center
        dateStack.distribution = .fillEqually
        dateStack.translatesAutoresizingMaskIntoConstraints = false
        leftView.addSubview(dateStack)
        
        // Right view (event name)
        let rightView = UIView()
        rightView.backgroundColor = .white
        rightView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        rightView.layer.cornerRadius = 12
        rightView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        rightView.addSubview(nameLabel)
        
        // Stack views horizontally
        let containerStack = UIStackView(arrangedSubviews: [leftView, rightView])
        containerStack.axis = .horizontal
        containerStack.spacing = 0
        containerStack.distribution = .fill
        containerStack.alignment = .fill
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(containerStack)
        
        // Constraints
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 60),
            
            container.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            container.topAnchor.constraint(equalTo: card.topAnchor),
            container.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            
            containerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            containerStack.topAnchor.constraint(equalTo: container.topAnchor),
            containerStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            leftView.widthAnchor.constraint(equalToConstant: 80),
            
            dateStack.centerXAnchor.constraint(equalTo: leftView.centerXAnchor),
            dateStack.centerYAnchor.constraint(equalTo: leftView.centerYAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: rightView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: rightView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: rightView.trailingAnchor, constant: -16),
        ])
        
        return card
    }

    
    
}
