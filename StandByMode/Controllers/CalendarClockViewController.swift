//
//  CalendarClockViewController.swift
//  StandByMode
//
//  Created by Coder ACJHP on 2.11.2023.
//

import UIKit

class CalendarClockViewController: UIViewController {
    
    private let hStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var analogClockView: AnalogClockView!
    private var calendarView: CalendarView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        setupSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        analogClockView.startClock()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        analogClockView.stopClock()
    }
    
    func setupSubViews() {
        
        let maxAllowedScreenWidth: CGFloat = 1180
        let maxAllowedScreenHeight: CGFloat = 800
        
        var hStackViewWidth = view.bounds.width
        if hStackViewWidth > maxAllowedScreenWidth {
            hStackViewWidth = maxAllowedScreenWidth
        }
        
        var hStackViewHeight = view.bounds.height
        if hStackViewHeight > maxAllowedScreenHeight {
            hStackViewHeight = maxAllowedScreenHeight
        }
        
        view.addSubview(hStackView)
        NSLayoutConstraint.activate([
            hStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            hStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            hStackView.widthAnchor.constraint(equalToConstant: hStackViewWidth),
            hStackView.heightAnchor.constraint(equalToConstant: hStackViewHeight)
        ])
        
        analogClockView = AnalogClockView(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: (hStackViewWidth / 2) - 10, height: view.bounds.height)
            )
        )
        hStackView.addArrangedSubview(analogClockView)
        
        let clockFrame = hStackView.arrangedSubviews.first!.bounds
        calendarView = CalendarView(frame: clockFrame)
        hStackView.addArrangedSubview(calendarView)
    }

}
