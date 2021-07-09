//
//  VKNewsFeedProfile.swift
//  VKApp
//
//  Created by Denis Kuzmin on 08.07.2021.
//

import Foundation

struct VKNewsFeedProfile: Decodable {
    let firstName: String
    let id: Int
    let lastName: String
    let sex: Int
    //let screenName: String
    let photoUrlString: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case id
        case lastName = "last_name"
        case sex
        case screenName = "screen_name"
        case photo50 = "photo_50"
        case photo100 = "photo_100"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try values.decode(String.self, forKey: .firstName)
        self.id = try values.decode(Int.self, forKey: .id)
        self.lastName = try values.decode(String.self, forKey: .lastName)
        self.sex = try values.decode(Int.self, forKey: .sex)
        //self.screenName = try values.decode(String.self, forKey: .screenName)
        let photo50 = try? values.decode(String.self, forKey: .photo50)
        let photo100 = try? values.decode(String.self, forKey: .photo100)
        if let photo = photo100 {
            self.photoUrlString = photo
        } else if let photo = photo50 {
            self.photoUrlString = photo
        } else {
            self.photoUrlString = "None"
        }
        self.fullName = "\(firstName) \(lastName)"
    }
}


/*
                "first_name": "Алексей",
                 "id": 242158733,
                 "last_name": "Кузьмин",
                 "can_access_closed": true,
                 "is_closed": false,
                 "sex": 2,
                 "screen_name": "id242158733",
                 "photo_50": "https://sun3-17.userapi.com/s/v1/ig1/EoWvMcKlRFHYpmETBmT7Y5gd69kAVodhjWF3m7Kj8vL4HgjPJdAd9I52MEKXQ8gNv32rIpQA.jpg?size=50x0&quality=96&crop=4,2,958,958&ava=1",
                 "photo_100": "https://sun3-17.userapi.com/s/v1/ig1/Lt4B9J8_J3yF0nv1nrETWJvKqZbpSWN45xOemeP6ZIbeGPppGfRGjDKeND4rN_8FYh2JPfF8.jpg?size=100x0&quality=96&crop=4,2,958,958&ava=1",
                 "online_info": {
                     "visible": true,
                     "last_seen": 1625772710,
                     "is_online": false,
                     "app_id": 2274003,
                     "is_mobile": true
                 },
                 "online": 0
             
 */
