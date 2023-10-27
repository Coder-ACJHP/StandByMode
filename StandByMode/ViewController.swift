//
//  ViewController.swift
//  Clock
//
//  Created by Coder ACJHP on 27.10.2023.
//

import UIKit

class ViewController: UIViewController {
 
    @IBOutlet weak var hourImageView: UIImageView!
    @IBOutlet weak var minuteImageView: UIImageView!
    @IBOutlet weak var secondsImageView: UIImageView!
    
    @IBOutlet weak var dayImageView: UIImageView!
    @IBOutlet weak var dayNameLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    // Media Buttons
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var trackListButton: UIButton!
    
    @IBOutlet weak var currentTrackNameLabel: UILabel!
    
    private var check = false
    private var value = 0
    private let currentDevice = UIDevice.current
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
        
        // Prevent screen lock
        UIApplication.shared.isIdleTimerDisabled = true
        UIScreen.main.brightness = 0.1
        
        setupSubViews()
        
        updateUI()
        
        let action = #selector(orientationChanged)
        NotificationCenter.default.addObserver(
            self,
            selector: action,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        currentDevice.beginGeneratingDeviceOrientationNotifications()
    }
    
    private final func setupSubViews() {
        
        let action = #selector(handleMediaButtonPress(_:))
        [shuffleButton, previousButton, playPauseButton, nextButton, trackListButton].forEach {
            $0?.imageView?.contentMode = .scaleAspectFit
            $0?.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    private final func updateUI() {
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            let today = Date()
            
            let currentHour = self.calendar.component(.hour, from: today)
            let currentMinute = self.calendar.component(.minute, from: today)
            let currentSecond = self.calendar.component(.second, from: today)
            
            self.hourImageView.image = UIImage(named: "\(currentHour)")
            self.minuteImageView.image = UIImage(named: "\(currentMinute)")
            self.secondsImageView.image = UIImage(named: "\(currentSecond)")
            
            // Date components
            let dayNumber = self.calendar.component(.day, from: today)
            self.dayImageView.image = UIImage(named: "\(dayNumber)")
            self.dateFormatter.dateFormat = "EEEE"
            self.dayNameLabel.text = self.dateFormatter.string(from: today)
            
            self.dateFormatter.dateFormat = "MMMM"
            self.monthLabel.text = self.dateFormatter.string(from: today)
            
        }
    }
    
    // MARK: - Action
    
    @objc
    private final func orientationChanged() {
        
//        switch currentDevice.orientation {
//        case .landscapeLeft, .landscapeRight:
//            // Transform 90 degrees
//            if check {
//                self.hourImageView.transform = self.hourImageView.transform.rotated(by: .pi / 2)
//                self.minuteImageView.transform = self.minuteImageView.transform.rotated(by: .pi / 2)
//                self.secondsImageView.transform = self.secondsImageView.transform.rotated(by: .pi / 2)
//                check = !check
//            }
//
//        case .portrait:
//            if value == .zero {
//                value += 1
//            } else {
//                self.hourImageView.transform = self.hourImageView.transform.rotated(by: .pi / -2)
//                self.minuteImageView.transform = self.minuteImageView.transform.rotated(by: .pi / -2)
//                self.secondsImageView.transform = self.secondsImageView.transform.rotated(by: .pi / -2)
//            }
//            check = true
//        default: break
//        }
    }
    
    @objc
    private final func handleMediaButtonPress(_ sender: UIButton) {
        
        switch sender {
        case shuffleButton:
            break
        case previousButton:
            break
        case playPauseButton:
            break
        case nextButton:
            break
        case trackListButton:
            break
        default: break
        }
    }
}

