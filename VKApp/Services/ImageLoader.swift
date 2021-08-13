//
//  ImageLoader.swift
//  VKApp
//
//  Created by Denis Kuzmin on 08.06.2021.
//

import UIKit

final class ImageLoader {

    static private var imageCache = NSCache<NSString, UIImage>()
    static private let cacheLifeTime: TimeInterval = 7 * 24 * 60 * 60
    //private let queue = DispatchQueue(label: "com.gb.isolationQ")
    
    private static let pathName: String = {
        let pathName = "Images"
        guard
            let cacheDir = FileManager
            .default
            .urls(
                for: .cachesDirectory,
                in: .userDomainMask)
            .first
        else { return pathName }
        let url = cacheDir
            .appendingPathComponent(
                pathName,
                isDirectory: true)
        if !FileManager
            .default
            .fileExists(atPath: url.path) {
            try? FileManager
                .default
                .createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil)
        }
        
        return pathName
    }()
    
    static private func getFilePath(at urlString: String) -> String? {
        guard
            let cacheDir = FileManager
                .default
                .urls(
                    for: .cachesDirectory,
                    in: .userDomainMask)
                .first,
            let fileName = urlString
                .split(separator: "/")
                .last?
                .split(separator: "?")
                .first
        else { return nil }
        return cacheDir
            .appendingPathComponent("\(ImageLoader.pathName)/\(fileName)")
            .path
    }
    
    static private func removeImageFromDisk(urlString: String) {
        guard
            let fileName = getFilePath(at: urlString),
            let url = URL(string: fileName),
            FileManager.default.fileExists(atPath: fileName)
        else { return }
        do {
            try FileManager
                .default
                .removeItem(at: url)
        } catch {
            print("ImageLoader Error: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: Save cache image
    static private func saveImageToDisk(
        urlString: String,
        image: UIImage) {
        guard let fileName = getFilePath(at: urlString) else { return }
        let data = image.pngData()
        FileManager
            .default
            .createFile(
                atPath: fileName,
                contents: data,
                attributes: nil)
    }
    
    // MARK: Load image cache
    static private func getImageFromDisk(urlString: String) -> UIImage? {
        guard
            let fileName = getFilePath(at: urlString),
            let fileInfo = try? FileManager
                .default
                .attributesOfItem(atPath: fileName),
            let modificationDate = fileInfo[FileAttributeKey.modificationDate]
                as? Date
        else { return nil }
        let lifetime = Date()
            .timeIntervalSince(modificationDate)
        guard
            lifetime <= cacheLifeTime,
            let image = UIImage(contentsOfFile: fileName)
        else {
            removeImageFromDisk(urlString: urlString)
            return nil
        }
        

        ImageLoader.imageCache.setObject(image, forKey: urlString as NSString)
        
        return image
    }
    
    static func getImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        if let image = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                completion(image)
            }
        }
        else if let image = getImageFromDisk(urlString: urlString){
            DispatchQueue.main.async {
                completion(image)
            }
        }
        else {
            loadImage(from: urlString, completion: completion)
        }
    }
    
    static private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        NetworkService.getData(from: urlString) { data in
            guard let image = UIImage(data: data) else { return completion(nil) }
            
            DispatchQueue.main.async {
                completion(image)
            }
            self.imageCache.setObject(image, forKey: urlString as NSString)
        }
    }
    
}


/*
 final class PhotoService {
     private var memoryCache = [String: UIImage]()
     private let cacheLifeTime: TimeInterval = 60 * 60 * 24 * 7
     
     private let isolationQ = DispatchQueue(label: "com.gb.isolationQ")
     
     
     
     
     
     // MARK: Remove cache image
     
     
     
     
     
     
     private func loadImage(
         urlString: String,
         complition: @escaping (UIImage?) -> Void) {
         AF
             .request(urlString)
             .responseData(queue: .global()) { [weak self] response in
                 guard
                     let self = self,
                     let data = response.data,
                     let image = UIImage(data: data)
                 else {
                     return complition(nil)
                 }
                 
                 self.isolationQ.async {
                     self.memoryCache[urlString] = image
                 }
                 self.saveImageToDisk(
                     urlString: urlString,
                     image: image)
                 
                 complition(image)
             }
     }
     
     // MARK: - Public API
     public func getImage(
         urlString: String,
         completion: @escaping (UIImage?) -> Void) {
         if let image = memoryCache[urlString] {
             completion(image)
         } else if let image = getImageFromDisk(urlString: urlString) {
             completion(image)
         } else {
             loadImage(
                 urlString: urlString,
                 complition: completion)
         }
     }
 }

 */
