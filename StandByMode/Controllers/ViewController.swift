//
//  ViewController.swift
//  StandByMode
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
    
    @IBOutlet weak var currentTrackNameLabel: MarqueeLabel!
    
    private var contextMenu: UICContextMenu!
    private let playerManager = MusicPlayerManager.shared
    private var playerItems: [MusicPlayerItemInfo] = []
    private var remoteControlMode: MusicRemoteControlMode = .skip
    
    private var check = false
    private var value = 0
    private let currentDevice = UIDevice.current
    private let tracks = DataProvider.shared.getLocalTracks()
    
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
        UIScreen.main.brightness = 0.0
        
        setupSubViews()
        
        updateUI()
        
        prepareDataSource()
        
        preparePlayer()
        
        let action = #selector(orientationChanged)
        NotificationCenter.default.addObserver(
            self,
            selector: action,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        currentDevice.beginGeneratingDeviceOrientationNotifications()
    }
    
    override  func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MarqueeLabel.controllerViewDidAppear(self)
    }
    
    private final func setupSubViews() {
        
        contextMenu = UICContextMenu(onViewController: self, trackList: tracks)
        contextMenu.delegate = self
        
        currentTrackNameLabel.fadeLength = 8
        
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
    
    // MARK: - Helpers
    
    private final func prepareDataSource() {
        
        for index in 0 ..< tracks.count {
            let track = tracks[index]
            let item = MusicPlayerItemInfo(
                id: index,
                url: track.fileURL,
                title: track.title,
                albumTitle: track.albumTitle,
                coverImageURL: nil,
                startAt: 0
            )
            playerItems.append(item)
        }
    }
    
    private final func preparePlayer() {
        
        playerManager.delegate = self
        playerManager.setup(with: playerItems, startFrom: 0, playAfterSetup: false)
    }
    
    func rotateView(_ targetView: UIView, duration: Double = 3.0) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = .infinity
        
        targetView.layer.add(rotateAnimation, forKey: nil)
    }
    
    fileprivate func setPlayPauseButtonImage(_ status: MusicPlayerStatus) {
        self.playPauseButton.layer.removeAllAnimations()
        switch status {
        case .loading, .none:
            self.playPauseButton.setImage(UIImage(named: "icon.loading.outline"), for: .normal)
            self.rotateView(self.playPauseButton)
        case .readyToPlay, .paused:
            self.playPauseButton.setImage(UIImage(named: "icon.play.filled"), for: .normal)
            
        case .playing:
            self.playPauseButton.setImage(UIImage(named: "icon.stop.filled"), for: .normal)
            
        case .failed:
            self.playPauseButton.setImage(UIImage(named: "icon.error.filled"), for: .normal)
        }
    }
    
    fileprivate func updateShuffleButtonStatus() -> Bool {
        shuffleButton.isSelected = !shuffleButton.isSelected
        self.shuffleButton.tintColor = shuffleButton.isSelected ? .green : .white
        let icon = UIImage(named: "icon.shuffle.filled")?.withRenderingMode(.alwaysTemplate)
        self.shuffleButton.setImage(icon, for: .normal)
        self.shuffleButton.setImage(icon, for: .selected)
        return shuffleButton.isSelected
    }
    
    // MARK: - Action
    
    @objc
    private final func changeRemoteControlMode() {
        self.remoteControlMode = self.remoteControlMode == .skip ? .nextprev : .skip
        playerManager.setCommandCenterMode(mode: self.remoteControlMode)
    }
    
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
            let status = updateShuffleButtonStatus()
            playerManager.shuffle(status)
            break
        case previousButton:
            playerManager.previous()
            break
        case playPauseButton:
            let status = playerManager.playOrPause()
            setPlayPauseButtonImage(status)
            break
        case nextButton:
            playerManager.next()
            break
        case trackListButton:
            contextMenu.showContextMenu(sender: trackListButton)
            break
        default: break
        }
    }
}

extension ViewController: UIContextMenuDelegate {
    
    func contextMenu(_ contextMenu: UICContextMenu?, didSelectTrack track: Track) {
        if let selectedItemIndex = playerItems.firstIndex(where: { $0.title == track.title }) {
            playerManager.goTo(selectedItemIndex)
        }
    }
    
    func contextMenu(_ contextMenu: UICContextMenu?, didCancelled: Bool) {
        print(#function)
    }
}

extension ViewController: MusicPlayerDelegate {
    
    func musicPlayerManager(_ playerManager: MusicPlayerManager, statusDidChange status: MusicPlayerStatus) {
        self.setPlayPauseButtonImage(status)
    }
    
    func musicPlayerManager(_ playerManager: MusicPlayerManager, itemDidChange itemIndex: Int) {
        currentTrackNameLabel.text = tracks[itemIndex].title
        contextMenu.setSelectedItem(itemIndex)
    }
    
    func musicPlayerManager(_ playerManager: MusicPlayerManager, progressDidUpdate percentage: Double) {
//        guard self.progressSlider.isEnabled && !self.progressSlider.isTracking else {
//            return
//        }
//
//        self.progressSlider.setValue(Float(percentage), animated: true)
//
//        self.timeLabel.text = self.stringFromTimeInterval(interval: playerManager.currentTime)
//        self.remainingLabel.text = self.stringFromTimeInterval(interval:(playerManager.duration - playerManager.currentTime))
        
    }
    
}
