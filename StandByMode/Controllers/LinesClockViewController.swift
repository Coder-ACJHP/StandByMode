//
//  LinesClockViewController.swift
//  StandByMode
//
//  Created by Coder ACJHP on 15.10.2024.
//

import UIKit

class LinesClockViewController: UIViewController {
    
    private lazy var hoursView: TimeDisplayView = {
        return TimeDisplayView(digits: [0,0])
    }()
    
    private let hoursSeparatorLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        label.font = UIFont(name: "OPTIPrisma-Caps", size: 80) ?? .boldSystemFont(ofSize: 80)
        label.textAlignment = .center
        label.text = ":"
        label.textColor = .white
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var minutesView: TimeDisplayView = {
        return TimeDisplayView(digits: [0,0])
    }()
    
    private let minutesSeparatorLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        label.font = UIFont(name: "OPTIPrisma-Caps", size: 80) ?? .boldSystemFont(ofSize: 80)
        label.textAlignment = .center
        label.text = ":"
        label.textColor = .white
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var secondsView: TimeDisplayView = {
        return TimeDisplayView(digits: [0,0])
    }()
    
    // Adjustable width constraints
    private var hoursWidthConstraint: NSLayoutConstraint!
    private var minutesWidthConstraint: NSLayoutConstraint!
    private var secondsWidthConstraint: NSLayoutConstraint!
    
    // Time updater timer
    private var timer: Timer?
    
    // Calendar for getting time components
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale.current
        c.timeZone = TimeZone.current
        return c
    }()
    
    // Size calculating variables
    private let itemSpace: CGFloat = 10
    private let separatorViewWidth: CGFloat = 30
    private var singleTimelineViewWidth: CGFloat = .zero {
        didSet {
            // Avoid twice updating for same value
            guard oldValue != singleTimelineViewWidth else { return }
            // Update items width constrainrs here
            updateItemsConstraints()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start updating time
        startTimeUpdater()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop and release updater
        stopTimeUpdater()
    }
    
    private func addSubviews() {
        
        view.addSubview(hoursView)
        hoursView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(hoursSeparatorLabel)
        hoursSeparatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(minutesView)
        minutesView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(minutesSeparatorLabel)
        minutesSeparatorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(secondsView)
        secondsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hoursView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hoursView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hoursView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            hoursSeparatorLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hoursSeparatorLabel.leadingAnchor.constraint(equalTo: hoursView.trailingAnchor, constant: itemSpace),
            hoursSeparatorLabel.widthAnchor.constraint(equalToConstant: separatorViewWidth),
            hoursSeparatorLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            minutesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            minutesView.leadingAnchor.constraint(equalTo: hoursSeparatorLabel.trailingAnchor, constant: itemSpace),
            minutesView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            minutesSeparatorLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            minutesSeparatorLabel.leadingAnchor.constraint(equalTo: minutesView.trailingAnchor, constant: itemSpace),
            minutesSeparatorLabel.widthAnchor.constraint(equalToConstant: separatorViewWidth),
            minutesSeparatorLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            secondsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            secondsView.leadingAnchor.constraint(equalTo: minutesSeparatorLabel.trailingAnchor, constant: itemSpace),
            secondsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        // Store width constraints to can update them later if needed
        hoursWidthConstraint = hoursView.widthAnchor.constraint(equalToConstant: singleTimelineViewWidth)
        hoursWidthConstraint.isActive = true
        minutesWidthConstraint = minutesView.widthAnchor.constraint(equalToConstant: singleTimelineViewWidth)
        minutesWidthConstraint.isActive = true
        secondsWidthConstraint = secondsView.widthAnchor.constraint(equalToConstant: singleTimelineViewWidth)
        secondsWidthConstraint.isActive = true
    }
    
    private func updateItemsConstraints() {
        // Change views width with new value
        hoursWidthConstraint.constant = singleTimelineViewWidth
        minutesWidthConstraint.constant = singleTimelineViewWidth
        secondsWidthConstraint.constant = singleTimelineViewWidth
        // Inform layout engine to redraw
        view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let separatorSpace: CGFloat = (separatorViewWidth * 2) + (itemSpace * 4)
        let totalWidth = view.bounds.inset(by: view.safeAreaInsets).width
        let remainingWidth = totalWidth - separatorSpace
        self.singleTimelineViewWidth = remainingWidth / 3
    }
    
    private func startTimeUpdater() {
        
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.updateDisplayingTime()
        })
    }
    
    private func stopTimeUpdater() {
        
        timer?.invalidate()
        timer = nil
    }
    
    private func updateDisplayingTime() {
        
        DispatchQueue.main.async { [self] in
            
            let now = Date()
            let components = self.calendar.dateComponents([.hour, .minute, .second], from: now)
            
            let hours = extractDigits(from: components.hour ?? 0)
            let minutes = extractDigits(from: components.minute ?? 0)
            let seconds = extractDigits(from: components.second ?? 0)
            
            hoursView.updateTime(digits: hours)
            minutesView.updateTime(digits: minutes)
            secondsView.updateTime(digits: seconds)
        }
    }
    
    // Helper function to extract digits from an integer
    func extractDigits(from value: Int) -> [Int] {
        return String(format: "%02d", value).compactMap { $0.wholeNumberValue }
    }
}
