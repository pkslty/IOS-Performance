//
//  VKNewsFeed.swift
//  VKApp
//
//  Created by Denis Kuzmin on 27.06.2021.
//

import Foundation

struct VKNewsFeed: Decodable {
    let items: [VKNew]
    let nextFrom: String?
    var profiles: [Int: VKNewsFeedProfile]
    var groups: [Int: VKNewsFeedGroup]
    
    enum CodingKeys: String, CodingKey {
        case items
        case nextFrom = "next_from"
        case profiles
        case groups
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try values.decode([VKNew].self, forKey: .items)
        self.nextFrom = try? values.decode(String.self, forKey: .nextFrom)
        let profiles = try values.decode([VKNewsFeedProfile].self, forKey: .profiles)
        self.profiles = [Int: VKNewsFeedProfile]()
        self.groups = [Int: VKNewsFeedGroup]()
        profiles.forEach { profile in
            self.profiles[profile.id] = profile
        }
        let groups = try values.decode([VKNewsFeedGroup].self, forKey: .groups)
        groups.forEach { group in
            self.groups[group.id] = group
        }
    }
}
