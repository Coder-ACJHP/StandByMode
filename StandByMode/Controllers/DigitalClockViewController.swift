//
//  DigitalClockViewController.swift
//  StandByMode
//
//  Created by Coder ACJHP on 1.11.2023.
//

import UIKit

class DigitalClockViewController: UIViewController {

    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var amPMLabel: UILabel!
    
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
        
    private var contextMenu: UICContextMenu!
    
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale.current
        c.timeZone = TimeZone.current
        return c
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    private final func updateUI() {
        
        UIView.animate(withDuration: 1.0, delay: .zero, options: [.curveLinear, .autoreverse, .repeat]) {
            self.secondsLabel.alpha = .zero
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            let today = Date()
            
            self.dateFormatter.dateFormat = "hh"
            self.hourLabel.text = self.dateFormatter.string(from: today)
            self.dateFormatter.dateFormat = "mm"
            self.minutesLabel.text = self.dateFormatter.string(from: today)
            self.dateFormatter.dateFormat = "a"
            self.amPMLabel.text = self.dateFormatter.string(from: today)
            
            // Date components
            let dayNumber = self.calendar.component(.day, from: today)
            self.dayNumberLabel.text = String(format: "%02d", dayNumber)
            self.dateFormatter.dateFormat = "EEE"
            self.dayNameLabel.text = self.dateFormatter.string(from: today).uppercased()
            
            self.dateFormatter.dateFormat = "MMM"
            self.monthLabel.text = self.dateFormatter.string(from: today).uppercased()
            
        }
    }

}
