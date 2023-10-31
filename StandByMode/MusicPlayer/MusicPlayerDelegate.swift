//
//  MusicPlayerDelegate.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import Foundation
import UIKit

public protocol MusicPlayerDelegate {
    func musicPlayerManager(_ playerManager: MusicPlayerManager, progressDidUpdate percentage: Double)
    func musicPlayerManager(_ playerManager: MusicPlayerManager, itemDidChange itemIndex: Int)
    func musicPlayerManager(_ playerManager: MusicPlayerManager, statusDidChange status: MusicPlayerStatus)
}
