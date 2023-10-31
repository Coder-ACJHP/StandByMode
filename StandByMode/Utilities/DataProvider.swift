//
//  DataProvider.swift
//  StandByMode
//
//  Created by Coder ACJHP on 31.10.2023.
//

import Foundation

class DataProvider {
    
    static let shared = DataProvider()

    private init() {}
    
    func getLocalTracks() -> Array<Track> {
        [
            Track(
                title: "Estas Tonne - Cappadocia Dust (Remastered)",
                albumTitle: "Anthology, Vol. I & Vol. II (Live)",
                fileURL: Bundle.main.url(forResource: "Capadocia", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Cycles of Life",
                albumTitle: "Cycles of Life",
                fileURL: Bundle.main.url(forResource: "CyclesOfLife", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Ancient Memories Winter Solstice Dreaming Version, Live in Vilnius",
                albumTitle: "Ancient Memories Winter Solstice",
                fileURL: Bundle.main.url(forResource: "AncientMemories", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Message from the Stars",
                albumTitle: "Message from the Stars",
                fileURL: Bundle.main.url(forResource: "MessageFromTheStars", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Fusion (Live) [Radio Edit]",
                albumTitle: "Fusion (Live) [Radio Edit]",
                fileURL: Bundle.main.url(forResource: "Fusion", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Eventide Dreams (Remastered)",
                albumTitle: "Anthology, Vol. I & Vol. II (Live)",
                fileURL: Bundle.main.url(forResource: "EventideDreams", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Internal Flight (Remastered)",
                albumTitle: "Internal Flight (Remastered)",
                fileURL: Bundle.main.url(forResource: "InternalFlight", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Introspection",
                albumTitle: "Introspection",
                fileURL: Bundle.main.url(forResource: "Introspection", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Paris Heart Variation (Live in Geneva)",
                albumTitle: "Paris Heart Variation (Live in Geneva)",
                fileURL: Bundle.main.url(forResource: "ParisHeart", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - Rebirth of a Thought: Between Fire & Water Kreuzkirche Dresden",
                albumTitle: "Rebirth of a Thought: Between Fire & Water",
                fileURL: Bundle.main.url(forResource: "RebirthOfAThoughBetween", withExtension: "mp3")
            ),
            Track(
                title: "Estas Tonne - When Words Are Wind",
                albumTitle: "When Words Are Wind",
                fileURL: Bundle.main.url(forResource: "WhenWordsAreWind", withExtension: "mp3")
            ),
        ]
    }
    
}
