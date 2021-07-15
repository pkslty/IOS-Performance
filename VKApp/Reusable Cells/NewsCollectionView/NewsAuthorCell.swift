//
//  NewsAuthorCell.swift
//  VKApp
//
//  Created by Denis Kuzmin on 18.04.2021.
//

import UIKit

class NewsAuthorCell: UICollectionViewCell {

    @IBOutlet weak var authorPhoto: RoundShadowView!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var postDate: UILabel!
    
    var task: URLSessionDataTask?


    func configure(id: Int? = nil, imageUrlString: String, name: String, date: Double, isRepost: Bool = false) {
        if id == nil {
            ImageLoader.getImage(from: imageUrlString) { [weak self] image in
                self?.authorPhoto.image = image
            }
            authorName.text = isRepost ? "\u{21a9} \(name)" : name
            postDate.text = NSDate(timeIntervalSince1970: date).description
            print("Celltext:\(authorName.text)")
        }
        else {
            task = NetworkService.getUserById(id: id!) { [weak self] user in
                print("Task Ended")
                self?.authorName.text = user.first!.fullName
                self?.postDate.text = NSDate(timeIntervalSince1970: date).description
                ImageLoader.getImage(from: user.first!.avatarUrlString) { [weak self] image in
                    self?.authorPhoto.image = image
                }
            }
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let task = task {
            task.cancel()
            print("task \(task.description) cancelled")
        }
    }
    
}
