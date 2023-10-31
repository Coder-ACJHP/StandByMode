//
//  MusicPlayerStatus.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import Foundation

public enum MusicPlayerStatus: Int {
    case none
    case loading
    case failed
    case readyToPlay
    case playing
    case paused
}
