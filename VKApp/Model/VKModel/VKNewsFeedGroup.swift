//
//  VKNewsFeedGroup.swift
//  VKApp
//
//  Created by Denis Kuzmin on 08.07.2021.
//

import Foundation

struct VKNewsFeedGroup: Decodable {
    let id: Int
    let name: String
    let screenName: String
    let type: String
    let photoUrlString: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case screenName = "screen_name"
        case type
        case photo50 = "photo_50"
        case photo100 = "photo_100"
        case photo200 = "photo_200"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.type = try values.decode(String.self, forKey: .type)
        self.screenName = try values.decode(String.self, forKey: .screenName)
        let photo50 = try? values.decode(String.self, forKey: .photo50)
        let photo100 = try? values.decode(String.self, forKey: .photo100)
        let photo200 = try? values.decode(String.self, forKey: .photo200)
        if let photo = photo200 {
            self.photoUrlString = photo
        } else if let photo = photo100 {
            self.photoUrlString = photo
        } else if let photo = photo50 {
            self.photoUrlString = photo
        } else {
            self.photoUrlString = "None"
        }
    }
}


/*
 {
                 "id": 147174,
                 "name": "Вера Полозкова",
                 "screen_name": "vera_polozkova",
                 "is_closed": 0,
                 "type": "group",
                 "is_admin": 0,
                 "is_member": 0,
                 "is_advertiser": 0,
                 "photo_50": "https://sun3-12.userapi.com/s/v1/ig2/hVUGgRs9vVfBCmgJJYIZTzuoRetXC7HtZ3N4xpA7qEgPr78REnH2lzaIjnfuj-ifYhBlG-WDzgn3quyRunozwn0J.jpg?size=50x0&quality=96&crop=105,37,577,577&ava=1",
                 "photo_100": "https://sun3-12.userapi.com/s/v1/ig2/3LSoFZ9vn_1Y2hAnO3R5zV-7GH6rTuFHoqR0VXvxhYBKdPnEFde_33tPKnoO_4mPn2-Oslib1xGSPKdQLRj0d_MO.jpg?size=100x0&quality=96&crop=105,37,577,577&ava=1",
                 "photo_200": "https://sun3-12.userapi.com/s/v1/ig2/RUq9hN0MRHOqN3q_x_p3DjD8xtvcAwlrWwnKWkduRe_M0f4r9L_cDb-fQ24coUBGk4qsxQhfat3ya_xWxiNmuTZw.jpg?size=200x0&quality=96&crop=105,37,577,577&ava=1"
             }
 */
