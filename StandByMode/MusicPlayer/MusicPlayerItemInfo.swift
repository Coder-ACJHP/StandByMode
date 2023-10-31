//
//  MusicPlayerItemInfo.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import UIKit

public class MusicPlayerItemInfo: Equatable {
    public var id: Int!
    public var url: URL!
    public var title: String!
    public var albumTitle: String!
    public var coverImage: UIImage!
    public var startAt: TimeInterval!
    
    public init(id: Int!, url: URL!, title: String!, albumTitle: String!, coverImageURL: String!, startAt: TimeInterval!) {
        self.id = id
        self.url = url
        self.title = title
        self.albumTitle = albumTitle
        
        if let urlStr = coverImageURL, let url = URL(string: urlStr) {
            DispatchQueue.global().async {
                if let data = try? Data( contentsOf:url)
                {
                    DispatchQueue.main.async {
                        self.coverImage = UIImage(data: data)
                    }
                }
            }
        }
        
        self.startAt = startAt
    }
    
    public init(id: Int!, url: URL!, title: String!, albumTitle: String!, coverImage: UIImage!, startAt: TimeInterval!) {
        self.id = id
        self.url = url
        self.title = title
        self.albumTitle = albumTitle
        self.coverImage = coverImage
        self.startAt = startAt
    }
    
    public static func == (lhs: MusicPlayerItemInfo, rhs: MusicPlayerItemInfo) -> Bool {
        return lhs.id == rhs.id || lhs.url == rhs.url
    }
}
