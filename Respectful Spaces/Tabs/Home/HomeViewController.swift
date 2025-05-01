import UIKit

class HomeViewController: BaseViewController {

    // MARK: - UI Elements
    let menuButton = UIButton(type: .system)
    let titleLabel = UILabel()
    let logoImageView = UIImageView()

    let segmentedControl = UISegmentedControl(items: ["Monthly", "Weekly", "Daily"])
    let calendarContainer = UIView()
    let monthlyCalendarView = UIView()
    let weeklyCalendarView = UIView()
    let dailyCalendarView = UIView()

    let upcomingLabel = UILabel()
    let upcomingEventsScrollView = UIScrollView()
    let upcomingEventsStack = UIStackView()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHeader()
        setupSegmentedControl()
        setupCalendarContainer()
        setupUpcomingEventsSection()
        layoutViews()
        showCalendar(type: .monthly)
    }

    // MARK: - Setup Methods

    func setupHeader() {
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        titleLabel.text = "Respectful Spaces"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        logoImageView.image = UIImage(systemName: "person.3.fill")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.tintColor = .label

        let headerStack = UIStackView(arrangedSubviews: [menuButton, titleLabel, logoImageView])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalCentering
        headerStack.alignment = .center
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(headerStack)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(calendarTypeChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
    }

    func setupCalendarContainer() {
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarContainer)

        // Placeholder views for each calendar type
        monthlyCalendarView.backgroundColor = .systemBlue
        weeklyCalendarView.backgroundColor = .systemGreen
        dailyCalendarView.backgroundColor = .systemOrange

        [monthlyCalendarView, weeklyCalendarView, dailyCalendarView].forEach {
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

    func setupUpcomingEventsSection() {
        upcomingLabel.text = "UPCOMING"
        upcomingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        upcomingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(upcomingLabel)

        upcomingEventsScrollView.translatesAutoresizingMaskIntoConstraints = false
        upcomingEventsStack.axis = .vertical
        upcomingEventsStack.spacing = 8
        upcomingEventsStack.translatesAutoresizingMaskIntoConstraints = false

        upcomingEventsScrollView.addSubview(upcomingEventsStack)
        view.addSubview(upcomingEventsScrollView)

        // Example event card placeholder
        for i in 1...5 {
            let card = UIView()
            card.backgroundColor = .secondarySystemBackground
            card.layer.cornerRadius = 10
            card.translatesAutoresizingMaskIntoConstraints = false
            let label = UILabel()
            label.text = "Event \(i)"
            label.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16)
            ])
            NSLayoutConstraint.activate([
                card.heightAnchor.constraint(equalToConstant: 60)
            ])
            upcomingEventsStack.addArrangedSubview(card)
        }

        NSLayoutConstraint.activate([
            upcomingEventsStack.topAnchor.constraint(equalTo: upcomingEventsScrollView.topAnchor),
            upcomingEventsStack.bottomAnchor.constraint(equalTo: upcomingEventsScrollView.bottomAnchor),
            upcomingEventsStack.leadingAnchor.constraint(equalTo: upcomingEventsScrollView.leadingAnchor),
            upcomingEventsStack.trailingAnchor.constraint(equalTo: upcomingEventsScrollView.trailingAnchor),
            upcomingEventsStack.widthAnchor.constraint(equalTo: upcomingEventsScrollView.widthAnchor)
        ])
    }

    func layoutViews() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            calendarContainer.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            calendarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarContainer.heightAnchor.constraint(equalToConstant: 300),

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
        monthlyCalendarView.isHidden = type != .monthly
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
}
