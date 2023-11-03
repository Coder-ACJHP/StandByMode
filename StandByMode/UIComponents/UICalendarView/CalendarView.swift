//
//  CalendarView.swift
//  StandByMode
//
//  Created by Coder ACJHP on 2.11.2023.
//

import Foundation
import UIKit

class CalendarView: UIView {
    
    private let monthYearLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .boldSystemFont(ofSize: 27)
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeButtonsHStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let changeAction: Selector = {
        return #selector(changeMonthHandler(_:))
    }()
    
    private lazy var leftButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "chevron.left"), for: .normal)
        btn.tintColor = .red
        btn.addTarget(self, action: changeAction, for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var rightButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "chevron.right"), for: .normal)
        btn.tintColor = .red
        btn.addTarget(self, action: changeAction, for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let weekDayNameStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var defaultLayout: UICollectionViewFlowLayout = {
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = .vertical
        return defaultLayout
    }()
    
    private lazy var calendarCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: defaultLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: DayCell.reusableIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale.current
        c.timeZone = TimeZone.current
        return c
    }()
    
    private var today = Date()
    private var days = Array<String>()
    private var weekDayNames = Array<String>()
    private var preferredCellHeight: CGFloat = 75
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initCommon()
    }
    
    private func initCommon() {
        
        weekDayNames = calendar.shortWeekdaySymbols
        weekDayNames.append(weekDayNames.removeFirst())
        
        setupSubViews()
        
        adjustValues()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            
            self.selectToday()
        }
    }
    
    override func layoutSubviews() {
        
        if let topAnchor = monthYearLabel.findConstraint(layoutAttribute: .top) {
            topAnchor.constant = frame.height / 5
        }
        
        super.layoutSubviews()
    }
    
    func setupSubViews() {
                
        // Add calendar container subviews here
        
        addSubview(monthYearLabel)
        NSLayoutConstraint.activate([
            monthYearLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            monthYearLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            monthYearLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 1),
            monthYearLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
        ])
        
        addSubview(changeButtonsHStackView)
        NSLayoutConstraint.activate([
            changeButtonsHStackView.topAnchor.constraint(equalTo: monthYearLabel.topAnchor),
            changeButtonsHStackView.leadingAnchor.constraint(equalTo: monthYearLabel.trailingAnchor, constant: 20),
            changeButtonsHStackView.widthAnchor.constraint(equalToConstant: 70),
            changeButtonsHStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        changeButtonsHStackView.addArrangedSubview(leftButton)
        changeButtonsHStackView.addArrangedSubview(rightButton)
        
        addSubview(weekDayNameStackView)
        NSLayoutConstraint.activate([
            weekDayNameStackView.topAnchor.constraint(equalTo: monthYearLabel.bottomAnchor, constant: 20),
            weekDayNameStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            weekDayNameStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            weekDayNameStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
        ])
        
        let collectionViewHeight = CGFloat(weekDayNames.count - 1) * preferredCellHeight
        addSubview(calendarCollectionView)
        NSLayoutConstraint.activate([
            calendarCollectionView.topAnchor.constraint(equalTo: weekDayNameStackView.bottomAnchor, constant: 20),
            calendarCollectionView.leadingAnchor.constraint(equalTo: weekDayNameStackView.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: weekDayNameStackView.trailingAnchor),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight)
        ])
    }
    
    func resetValues() {
        
        weekDayNameStackView.arrangedSubviews.forEach({
            weekDayNameStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        dateFormatter.dateFormat = "MMMM yyyy"
        
        days.removeAll(keepingCapacity: false)
    }
    
    func adjustValues() {
        
        monthYearLabel.text = dateFormatter.string(from: today)
        
        // Draw week day names
        for (index, dayName) in weekDayNames.enumerated() {
            
            let label = UILabel(frame: .zero)
            label.tag = index
            label.font = .systemFont(ofSize: 18, weight: .semibold)
            label.text = dayName.uppercased()
            label.textColor = .lightGray
            label.textAlignment = .center
            
            weekDayNameStackView.addArrangedSubview(label)
            label.sizeToFit()
        }
        
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        
        // Find first day index in current month
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        dateFormatter.dateFormat = "EEE"
        if let firstDayOfMonth = Date.from(year: year, month: month, day: 1) {
            let dayShortName = dateFormatter.string(from: firstDayOfMonth)
            if let firstDayIndex = weekDayNames.firstIndex(where: { $0 == dayShortName }) {
                // Get current month days range
                if let range = calendar.range(of: .day, in: .month, for: today) {
                    // Populate days array with values
                    for index in -firstDayIndex ... range.count - 1 {
                        days.append(index >= .zero ? "\(index + 1)" : "")
                    }
                    // Reload collectionView
                    calendarCollectionView.reloadData()
                }
            }
        }
    }
    
    private final func selectToday() {
        
        // Select today by default
        let dayNumber = calendar.component(.day, from: today)
        guard let dayIndex = days.firstIndex(where: { $0 == String(dayNumber) }) else { return }
        let indexPath = IndexPath(item: dayIndex, section: 0)
        if let cell = calendarCollectionView.cellForItem(at: indexPath) as? DayCell {
            cell.layoutSubviews()
            calendarCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private final func changeMonthHandler(_ sender: UIButton) {
        
        var additionalNumber: Int = .zero
        
        if sender == leftButton {
            additionalNumber = -1
        } else {
            additionalNumber = 1
        }

        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)
        if let date = Date.from(year: year, month: (month + additionalNumber), day: day) {
            
            self.today = date
            self.resetValues()
            self.adjustValues()
        }
    }
}

extension CalendarView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableSpace = collectionView.frame.width - (CGFloat(weekDayNames.count - 1) * 10)
        let cellWidth = availableSpace / CGFloat(weekDayNames.count)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let day = days[indexPath.item]
        
        guard let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.reusableIdentifier, for: indexPath) as? DayCell else {
            fatalError("No cell with xxx identifier!")
        }
        
        dayCell.configure(with: day)
        return dayCell
    }
}
