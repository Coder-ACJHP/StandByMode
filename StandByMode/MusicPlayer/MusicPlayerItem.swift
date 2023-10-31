//
//  MusicPlayerItem.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import Foundation
import AVFoundation

class MusicPlayerItem: AVPlayerItem {
    var index: Int!
    var itemInfo: MusicPlayerItemInfo!
    
    init(asset: AVAsset, index: Int, itemInfo: MusicPlayerItemInfo! = nil) {
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
        if let startAt = itemInfo.startAt {
            super.seek(to: CMTime(seconds: startAt , preferredTimescale: Defaults.preferredTimescale), completionHandler: nil)
        }
        self.index = index
        self.itemInfo = itemInfo
    }
}

