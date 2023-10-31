//
//  Constants.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import MediaPlayer

// default config values
final class Defaults {
    static let progressTimerInterval: CMTime = CMTime(value: 1, timescale: 1)
    static let preferredTimescale: CMTimeScale = 1000
    static let skipIntervalInSeconds: TimeInterval = 15.0
    static let playbackRates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    static let commandCenterMode = MusicRemoteControlMode.skip
}
