//
//  MusicQueuePlayer.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import Foundation
import AVFoundation

class MusicQueuePlayer: AVQueuePlayer {
    var currentIndex: Int! {
        if let item = self.currentItem as? MusicPlayerItem {
            return item.index
        }
        return nil
    }
}

extension AVQueuePlayer {
    func goTo(index: Int, with initialItems: [AVPlayerItem]) {
        self.removeAllItems()
        let newItems = initialItems.dropFirst(index)
        for item in newItems {
            if self.canInsert(item, after: nil) {
                self.insert(item, after: nil)
            }
        }
    }
    
    func addProgressObserver(action:@escaping ((Double) -> Void)) -> Any {
            return self.addPeriodicTimeObserver(forInterval: Defaults.progressTimerInterval, queue: .main, using: { [weak self] time in
                if let duration = self?.currentItem?.duration {
                    let duration = CMTimeGetSeconds(duration), time = CMTimeGetSeconds(time)
                    let progress = (time/duration)
                    action(progress)
                }
            })
        }
}
