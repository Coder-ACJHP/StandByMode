//
//  MusicPlayerManager.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import AVFoundation
import MediaPlayer

public final class MusicPlayerManager: NSObject {
    
    static public let shared = MusicPlayerManager()
    
    public var delegate: MusicPlayerDelegate?
    
    fileprivate let commandCenter = MPRemoteCommandCenter.shared()
    fileprivate var qPlayer: MusicQueuePlayer?
    fileprivate var qPlayerItems: [MusicPlayerItem] = []
    fileprivate var qPlayerObserverRef: Any?
    fileprivate var isSessionSetup = false    
    fileprivate var isSeeking = false

    public var playerStatus: MusicPlayerStatus {
        return self.status
    }
    public var playbackRates: [Float] = Defaults.playbackRates
    public var rate: Float = 1.0
    public var skipIntervalInSeconds = Defaults.skipIntervalInSeconds {
        didSet {
            self.commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: self.skipIntervalInSeconds)]
            self.commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: self.skipIntervalInSeconds)]
        }
    }
    fileprivate var status: MusicPlayerStatus = .none {
        didSet {
            self.delegate?.musicPlayerManager(self, statusDidChange: status)
        }
    }
    public var currentItemInfo: MusicPlayerItemInfo! {
        return (self.qPlayer?.currentItem as? MusicPlayerItem)?.itemInfo ?? nil
    }
    public var currentItemIndex: Int {
       return (self.qPlayer?.currentItem as? MusicPlayerItem)?.index ?? -1
    }
    public var currentTime: TimeInterval {
        return self.qPlayer?.currentItem?.currentTime().seconds ?? 0
    }
    public var duration: TimeInterval {
        return self.qPlayer?.currentItem?.asset.duration.seconds ?? 0
    }
    public var percentage: Double {
        guard let duration = qPlayer?.currentItem?.asset.duration else {
            return 0.0
        }
        
        let currentTime = self.qPlayer?.currentTime() ?? .zero
        return currentTime.seconds / duration.seconds
    }
    
    public override init() {
        super.init()
        
        self.setupRemoteControl()
    }
    
    deinit {
        UIApplication.shared.endReceivingRemoteControlEvents()
        self.clean()
    }
    
    public func clean() {
        qPlayer?.pause()
        qPlayer?.removeAllItems()
        if let qPlayerObserverRef = qPlayerObserverRef {
            qPlayer?.removeTimeObserver(qPlayerObserverRef)
        }
        qPlayer = nil
        qPlayerItems.removeAll()
    }
    
    public func setup(with items: [MusicPlayerItemInfo], startFrom: Int = 0, playAfterSetup: Bool = false) {
        
        self.clean()
        self.status = .loading
        
        guard items.count > 0 else {
            return
        }
        
        // init new items
        for item in items {
            guard let url = item.url else {
                debugPrint("missing item url")
                continue
            }
            
            let asset = AVAsset(url: url)
            let item = MusicPlayerItem(asset: asset, index: self.qPlayerItems.count, itemInfo: item)
            qPlayerItems.append(item)
        }
        
        // validate startFrom item index
        var toDrop = startFrom
        if startFrom < 0 {
            toDrop = 0
        }
        if startFrom >= items.count {
            toDrop = items.count - 1
        }
        
        // init the AQQueuePlayer
        qPlayer = MusicQueuePlayer(items: Array(qPlayerItems.dropFirst(toDrop)))
        qPlayerObserverRef = qPlayer?.addProgressObserver(action: { (progress) in
            DispatchQueue.main.async {
                self.updateProgress(progress: progress)
            }
        })
        
        let keysToObserve = ["currentItem","rate"]
        for key in keysToObserve {
            qPlayer?.addObserver(self, forKeyPath: key, options: [.new, .old, .initial], context: nil)
        }
        
        if playAfterSetup {
            self.play()
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        debugPrint(String(describing: keyPath))
       
        
        guard let item = self.qPlayer?.currentItem as? MusicPlayerItem else {
            self.status = .none
            return
        }
       
        switch keyPath {
        case "currentItem":
            self.status = .loading
            qPlayer?.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                self.updateNowPlaying()
                self.delegate?.musicPlayerManager(self, itemDidChange: item.index)
            break
            
        case "status":
            if let item = object as? AVPlayerItem {
                switch (item.status) {
                case .unknown:
                    self.status = .none
                case .readyToPlay:
                    if qPlayer?.rate ?? 0 > 0 {
                        self.status = .playing
                    } else {
                        self.status = .readyToPlay
                    }
                case .failed:
                    self.status = .failed
                @unknown default:
                    self.status = .failed
                }
            }
            break
        case "rate":
            if let player = self.qPlayer {
                self.status = player.rate > 0 ? .playing : .paused
            } else {
                self.status = .none
            }
            break
       
        default:
            debugPrint("KeyPath: \(String(describing: keyPath)) not handeled in observer")
        }
       
    }
    
    public func setCommandCenterMode(mode: MusicRemoteControlMode) {
            commandCenter.skipBackwardCommand.isEnabled = (mode == .skip)
            commandCenter.skipForwardCommand.isEnabled = (mode == .skip)
        
            commandCenter.nextTrackCommand.isEnabled = (mode == .nextprev)
            commandCenter.previousTrackCommand.isEnabled = (mode == .nextprev)
        
            commandCenter.seekForwardCommand.isEnabled = false
            commandCenter.seekBackwardCommand.isEnabled = false
            commandCenter.changePlaybackRateCommand.isEnabled = false
    }
    
    fileprivate func setupAudioSession() {
        // activate audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default , policy: .longForm, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            isSessionSetup = true
        } catch {
            print("Activate AVAudioSession failed.")
        }
    }

    @objc fileprivate func updateProgress(progress: Double) {
        guard let delegate = self.delegate, !progress.isNaN, isSeeking == false else {
            return
        }
        
        if self.status != .playing, qPlayer?.status == .readyToPlay, qPlayer?.rate ?? 0 > 0 {
            self.status = .playing
        }
        
        delegate.musicPlayerManager(self, progressDidUpdate: progress)
        
    }
    
    fileprivate func updateNowPlaying(time: TimeInterval? = nil) {
        guard self.duration > 0.0 else {
            return
        }
        
        var nowPlayingInfo:[String: Any]? = MPNowPlayingInfoCenter.default().nowPlayingInfo
        if nowPlayingInfo == nil {
            nowPlayingInfo = [String: Any]()
        }
        
        guard let item = self.qPlayer?.currentItem as? MusicPlayerItem else {
            return
        }
        
        // init metadata
        nowPlayingInfo?[MPMediaItemPropertyTitle] = item.itemInfo.title
        nowPlayingInfo?[MPMediaItemPropertyAlbumTitle] = item.itemInfo.albumTitle
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (time == nil) ? self.qPlayer?.currentTime().seconds ?? 0 : time
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = self.duration
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = self.qPlayer?.rate ?? 0
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        self.updateMediaItemArtwork()
    }
    fileprivate func updateMediaItemArtwork() {
        // set cover image
        if let item = self.qPlayer?.currentItem as? MusicPlayerItem, let image = item.itemInfo.coverImage {
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
        }
//        else {
//            self.delegate?.getCoverImage(self, { (coverImage) in
//                if let image = coverImage {
//                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
//                }
//            })
//        }
    }
}

// MARK: Audio control methods
extension MusicPlayerManager {
    public func playOrPause() -> MusicPlayerStatus {
        guard qPlayer != nil, qPlayer?.currentItem != nil else {
            return .none
        }
        
        switch self.status {
            case .loading, .none:
                return .loading
        case .failed:
            return .failed
            
            
            case .readyToPlay, .paused:
                self.play()
                return .playing
            case .playing:
                self.pause()
                return.paused
        }
    }
    
    public func play() {
        guard qPlayer != nil, qPlayer?.currentItem != nil else {
            return
        }
        
        if !isSessionSetup {
            setupAudioSession()
        }
        
        self.qPlayer?.playImmediately(atRate: self.rate)
        //self.status = .playing
        self.updateProgress(progress: 0)
        self.updateNowPlaying()
        
    }
    
    public func pause() {
        guard qPlayer != nil else {
            return
        }
        
        qPlayer?.pause()
        self.status = .paused
    }
    
    public func seek(toPercent: Double) {
        let duration = qPlayer?.currentItem?.duration ?? .zero
        let jumpToSec = duration.seconds * toPercent
        
        self.seek(toTime: jumpToSec)
    }
    
    public func seek(toTime: TimeInterval) {
        self.isSeeking = true
        var playAfterSeek = false
        if self.status == .playing {
            self.pause()
            playAfterSeek = true
        }
        
        self.status = .loading
        self.qPlayer?.seek(to: CMTime(seconds: toTime, preferredTimescale: Defaults.preferredTimescale) , completionHandler: { (value) in
            if playAfterSeek {
                self.play()
            }
            self.isSeeking = false
        })
    }
    
    public func next() {
        guard qPlayer != nil, let index = self.qPlayer?.currentIndex, index < self.qPlayerItems.count - 1 else {
            return
        }
        
       self.goTo(index + 1)
    }
    
    public func previous() {
        guard qPlayer != nil, let index = self.qPlayer?.currentIndex, index > 0 else {
            return
        }
        
        self.goTo(index - 1)
    }
    
    public func goTo(_ index: Int) {
        guard qPlayer != nil, index >= 0, index < self.qPlayerItems.count else {
            return
        }
        
        var playAfterGo = false
        if self.status == .playing {
            self.pause()
            playAfterGo = true
        }
        
        qPlayer?.goTo(index: index, with: self.qPlayerItems)
        
        if playAfterGo {
            self.play()
        }
        
    }
    
    public func skipForward() {
        
        let currentTime = self.qPlayer?.currentTime() ?? .zero
        var jumpToSec = currentTime + CMTime(seconds: self.skipIntervalInSeconds, preferredTimescale: Defaults.preferredTimescale) // dalta
        let duration = qPlayer?.currentItem?.duration ?? .zero
        
        if jumpToSec > duration {
            jumpToSec = duration
        }
        
        guard jumpToSec >= .zero else {
            return
        }
        
        self.seek(toTime: jumpToSec.seconds)   
    }
    
    public func skipBackward() {
        self.pause()
        let currentTime = self.qPlayer?.currentTime() ?? .zero
        var jumpToSec = currentTime - CMTime(seconds: self.skipIntervalInSeconds, preferredTimescale: Defaults.preferredTimescale) // dalta
        // let duration = qPlayer?.currentItem?.duration ?? .zero
        
        if jumpToSec < .zero {
            jumpToSec = .zero
        }
        
        guard jumpToSec >= .zero else {
            return
        }
        
        self.qPlayer?.seek(to: jumpToSec, completionHandler: { (value) in
            self.play()
        })
    }
    
    public func changeToNextRate() -> Float {
        guard let index = self.playbackRates.lastIndex(of: self.rate) else {
            self.rate = 1.0
            return 1.0
        }
        
        var newRateIndex = index + 1
        if newRateIndex == playbackRates.count {
            newRateIndex = 0
        }
        
        self.rate = self.playbackRates[newRateIndex]
        self.qPlayer?.rate = self.rate
        
        return self.rate
    }
    
    public func shuffle(_ status: Bool) {
        if status {
            self.qPlayerItems.shuffle()
        } else {
            self.qPlayerItems.sort(by: { $0.itemInfo.id < $1.itemInfo.id })
        }
    }
}

// Remote Control Setup
extension MusicPlayerManager {
    fileprivate func setupRemoteControl() {
        
        self.setCommandCenterMode(mode: Defaults.commandCenterMode)
        
        // MARK: Remote Commands handlers
        
        // play , pause , stop
        commandCenter.togglePlayPauseCommand.addTarget(handler: {[weak self]  (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("togglePlayPauseCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            if strongSelf.playOrPause() != .none {
                return .success
            } else {
                return .commandFailed
            }
        })
        commandCenter.playCommand.addTarget { [weak self] event in
            debugPrint("playCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.play()
            return checkSatatus(strongSelf)
        }
        commandCenter.pauseCommand.addTarget { [weak self] event in
            debugPrint("pauseCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.pause()
           return checkSatatus(strongSelf)
        }
        commandCenter.stopCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("stopCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.pause()
            return checkSatatus(strongSelf)
        })
        
        // next , prev
        commandCenter.nextTrackCommand.addTarget( handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("nextTrackCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.next()
            return checkSatatus(strongSelf)
        })
        commandCenter.previousTrackCommand.addTarget( handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("previousTrackCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.previous()
            return checkSatatus(strongSelf)
        })
        
        // seek fwd , seek bwd
        commandCenter.seekForwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("seekForwardCommand")
            guard self != nil else {return .commandFailed}
            
            debugPrint("Seek forward ")
            return .commandFailed
        })
        commandCenter.seekBackwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("seekBackwardCommand")
            guard self != nil else {return .commandFailed}
            
            debugPrint("Seek backward ")
            return .commandFailed
        })
       
        // skip fwd , skip bwd
        commandCenter.skipForwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("skipForwardCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.skipForward()
            return checkSatatus(strongSelf)
        })
        commandCenter.skipBackwardCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("skipBackwardCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            strongSelf.skipBackward()
            return checkSatatus(strongSelf)
        })

        // playback rate
        commandCenter.changePlaybackRateCommand.addTarget(handler: {[weak self] (_) -> MPRemoteCommandHandlerStatus in
            debugPrint("changePlaybackRateCommand")
            guard self != nil else {return .commandFailed}
            
            debugPrint("Change Rate ")
            return .commandFailed
        })
        
        // seek to position
        commandCenter.changePlaybackPositionCommand.addTarget(handler: {[weak self] ( event) -> MPRemoteCommandHandlerStatus in
            debugPrint("changePlaybackPositionCommand")
            guard let strongSelf = self else {return .commandFailed}
            
            //   var playAfterSeek = strongSelf.status == .playing
            // strongSelf.pause()
            
            let e = event as! MPChangePlaybackPositionCommandEvent
            strongSelf.updateNowPlaying(time: e.positionTime)
            strongSelf.seek(toTime: e.positionTime)
            return checkSatatus(strongSelf)
            
        })
        
        // check status and return MPRemoteCommandHandlerStatus
        func checkSatatus(_ strongSelf: MusicPlayerManager) -> MPRemoteCommandHandlerStatus {
            if strongSelf.status != .none {
                return .success
            } else {
                return .commandFailed
            }
        }
        
        // Enters Background
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: {[weak self] (_) in
            debugPrint("willResignActiveNotification")
            guard let strongSelf = self else {return}
            
            strongSelf.updateNowPlaying()
        })
    }
}

public enum MusicRemoteControlMode {
    case skip
    case nextprev
}
