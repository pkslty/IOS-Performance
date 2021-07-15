//
//  NetworkService.swift
//  VKApp
//
//  Created by Denis Kuzmin on 24.05.2021.
//

import UIKit

class NetworkService {
    static private let session = URLSession.shared
    static private var url: URLComponents = {
        var urlConstructor = URLComponents()
        urlConstructor.scheme = "https"
        urlConstructor.host = "api.vk.com"
        return urlConstructor
        }()
    static private let api_version = "5.132"
    
    
    static func getFriends(of userId: Int = Session.Instance.userId, completionBlock: @escaping ([VKRealmUser]) -> Void) {
        let parameters = [
            "order" : "hints",
            "fields" : "nickname,photo_200_orig",
            "user_id" : String(userId),
        ]
        request(method: "friends.get", parameters: parameters) { data in
            guard let vkResponse = try? JSONDecoder().decode(VKResponse<VKItems<VKRealmUser>>.self, from: data)
            else {
                print("JSON Decode fail")
                return
            }
            completionBlock(vkResponse.response.items)
        }
    }
    
    static func getUserById(id: Int, completionBlock: @escaping ([VKUser]) -> Void) -> URLSessionDataTask? {
        //DispatchQueue.global().async {
            let parameters = [
                "user_ids" : String(id),
                "fields" : "photo_200_orig",
            ]
            let task = request(method: "users.get", parameters: parameters) { data in
                do {
                    let vkResponse = try JSONDecoder().decode(VKResponse<[VKUser]>.self, from: data)
                    completionBlock(vkResponse.response)
                }
                catch let error {
                    print("JSON error: \(error)")
                    print("DATA is \(data)")
                    let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                    print("JSON is \(String(describing: json))")
                    return
                }
            }
        //}
        return task
    }
    
    static func getGroupById(id: Int, completionBlock: @escaping ([VKGroup]) -> Void) -> URLSessionDataTask? {
        let parameters = [
            "group_ids" : String(id),
            "fields" : "photo_200",
        ]
        let task = request(method: "groups.getById", parameters: parameters) { data in
            do {
                let vkResponse = try JSONDecoder().decode(VKResponse<[VKGroup]>.self, from: data)
                completionBlock(vkResponse.response)
            }
            catch let error {
                print("JSON error: \(error)")
                print("DATA is \(data)")
                let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                print("JSON is \(String(describing: json))")
                return
            }
        }
        return task
    }
    
    static func performVkMethod(method: String, with parameters: [String: String], token: String = Session.Instance.token, completionBlock: @escaping (Data) -> Void) -> URLSessionDataTask? {
        return request(method: method, parameters: parameters, token: token) { data in
            completionBlock(data)
        }
    }
    
    static func getGroups(of userId: Int = Session.Instance.userId, callBack: @escaping ([VKRealmGroup]) -> Void) {
        let parameters = [
            "extended" : "1",
            "user_id" : String(userId),
        ]
        
        request(method: "groups.get", parameters: parameters) { data in
            guard let vkResponse = try? JSONDecoder().decode(VKResponse<VKItems<VKRealmGroup>>.self, from: data)
            else {
                print("JSON Decode fail")
                print("DATA is \(data)")
                let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                print("JSON is \(json)")
                return
            }
            callBack(vkResponse.response.items)
        }
    }
    
    static func searchGroups(by query: String, resultsCount: Int, completionBlock: @escaping ([VKRealmGroup]) -> Void) {
        let parameters = [
            "q" : query,
            "count" : String(resultsCount),
        ]
        request(method: "groups.search", parameters: parameters) { data in
            guard let vkResponse = try? JSONDecoder().decode(VKResponse<VKItems<VKRealmGroup>>.self, from: data)
            else {
                print("JSON Decode fail")
                print("DATA is \(data)")
                let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                print("JSON is \(json)")
                return
            }
            completionBlock(vkResponse.response.items)
        }

    }
    
    static func getNewsFeed(count: Int = 100, start_from: String, completionBlock: @escaping ([VKNew], String, [Int: VKNewsFeedProfile], [Int: VKNewsFeedGroup]) -> Void) {
        
        performVkMethod(method: "newsfeed.get", with: ["count":"100", "filters":"post"]) { data in
            //let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            do {
                let response = (try JSONDecoder().decode(VKResponse<VKNewsFeed>.self, from: data)).response
                //print("JSON: \(json)")
                //print("VKNEWS: \(self?.vkNews)")
                DispatchQueue.main.async {
                    completionBlock(response.items,
                                    response.nextFrom ?? "none",
                                    response.profiles,
                                    response.groups)
                }
            } catch let error {
                print("Error in parsing NewsFeed: \(error)")
            }
        }
    }
    
    static func getPhotos(of userId: Int, completionBlock: @escaping ([VKRealmPhoto]) -> Void) {
        let parameters = [
            "owner_id" : String(userId),
            "extended" : "1",
        ]
        request(method: "photos.getAll", parameters: parameters) { data in
            guard let vkResponse = try? JSONDecoder().decode(VKResponse<VKItems<VKRealmPhoto>>.self, from: data)
            else {
                print("JSON Decode fail")
                print("DATA is \(data)")
                let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                print("JSON is \(json)")
                return
            }
            DispatchQueue.main.async {
                completionBlock(vkResponse.response.items)
            }
        }

    }
    
    static private func request(method: String, parameters: [String: String], token: String = Session.Instance.token, completionBlock: @escaping (Data) -> Void) -> URLSessionDataTask? {
            url.path = "/method/" + method
            url.queryItems = [
                URLQueryItem(name: "access_token", value: token),
                URLQueryItem(name: "v", value: api_version)]
            for (parameter, value) in parameters {
                url.queryItems?.append(
                    URLQueryItem(name: parameter, value: value))
            }
            
            guard let url = url.url else { return nil}
            print(url)
            
        let task = session.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    print("Request error: \(String(describing: error))")
                    return
                }
                guard let data = data else { return }
                DispatchQueue.main.async {
                    completionBlock(data)
                }
                
            }
            task.resume()
        return task

    }
    
    static func getData(from url: String, completionBlock: @escaping (Data) -> Void) {
        guard let url = URL(string: url)
        else {
            print("NetworkService error: Invalid url")
            return
        }
        DispatchQueue.global().async {
            let task = session.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    print("NetworkService error: \(String(describing: error))")
                    print("URL: \(url)")
                    return
                }
                guard let data = data
                else {
                    print("NetworkService error: No data")
                    return
                }
                DispatchQueue.main.async {
                    completionBlock(data)
                }
            }
            task.resume()
        }
    }
    
}
