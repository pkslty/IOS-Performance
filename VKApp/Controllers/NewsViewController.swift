//
//  NewsViewController.swift
//  VKApp
//
//  Created by Denis Kuzmin on 17.04.2021.
//

import UIKit

class NewsViewController: UIViewController, UICollectionViewDelegate{

    enum cellTypes {
        case author
        case repostAuthor
        case text
        case photo
        case attachment
        case actions
        case link
        case attachmentPhoto
        case video
    }
    struct cellDataDescription {
        var type: cellTypes
        var photoNum: Int?
    }
    
    @IBOutlet weak var newsCollection: UICollectionView!
    var posts = [Post]()
    var vkNews = [VKNew]()
    var nextFrom = String()
    var postIsCollapsed = [Bool]()
    var cellType = [Int: Int]()
    //Dictionary for cells types:
    var cellsTypes = [Int: [Int: cellTypes]]()
    var cellsDataDesriptions = [Int: [Int: cellDataDescription]]()
    var profiles = [Int: VKNewsFeedProfile]()
    var groups = [Int: VKNewsFeedGroup]()
    
    //var textCellHeightsThatFits = [CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsCollection.register(UINib(nibName: "NewsAuthorCell", bundle: nil), forCellWithReuseIdentifier: "NewsAuthorCell")
        newsCollection.register(UINib(nibName: "NewsTextCell", bundle: nil), forCellWithReuseIdentifier: "NewsTextCell")
        newsCollection.register(UINib(nibName: "NewsImageCell", bundle: nil), forCellWithReuseIdentifier: "NewsImageCell")
        newsCollection.register(UINib(nibName: "NewsActionsCell", bundle: nil), forCellWithReuseIdentifier: "NewsActionsCell")
        newsCollection.register(UINib(nibName: "NewsVideoCell", bundle: nil), forCellWithReuseIdentifier: "NewsVideoCell")
        
        NetworkService.getNewsFeed(start_from: "") { [weak self] vkNews, nextFrom, profiles, groups in
            self?.vkNews = vkNews
            self?.nextFrom = nextFrom
            self?.profiles = profiles
            self?.groups = groups
            self?.newsCollection.reloadData()
        }
        
        //newsCollection.backgroundColor = .systemBackground
        
        
    }
    

}

extension NewsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return vkNews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var cellType = [Int: cellTypes]()
        var cellDescriptor = [Int: cellDataDescription]()
        var photosNum = 0
        var currentItem = 0
        var numberOfItems = 1
        var vkNew: VKNew
        cellType[currentItem] = .author
        cellDescriptor[currentItem] = cellDataDescription(type: .author)
        if let repost = vkNews[section].copyHistory,
           repost.count > 0 {
            vkNew = repost.first!
            currentItem += 1
            numberOfItems += 1
            cellDescriptor[currentItem] = cellDataDescription(type: .repostAuthor)
        } else {
            vkNew = vkNews[section]
        }
        if vkNew.text != nil {
            numberOfItems += 1
            currentItem += 1
            cellType[currentItem] = .text
            cellDescriptor[currentItem] = cellDataDescription(type: .text)
        }
        if let photos = vkNew.photos {
            photos.items.enumerated().forEach { (num, photo) in
                //photosNum += 1
                numberOfItems += 1
                currentItem += 1
                DispatchQueue.global(qos: .background).async {
                    ImageLoader.getImage(from: (photo.imageUrlString)!) { image in
                        print("\(String(describing: image?.description)) loaded")
                    }
                }
                cellDescriptor[currentItem] = cellDataDescription(type: .photo, photoNum: num)
            }
        }
        if let attachments = vkNew.attachments {
            attachments.enumerated().forEach { (num, attachment) in
                switch attachment.type {
                case "photo":
                    numberOfItems += 1
                    currentItem += 1
                    cellDescriptor[currentItem] = cellDataDescription(type: .attachmentPhoto, photoNum: num)
                    DispatchQueue.global(qos: .background).async {
                        ImageLoader.getImage(from: (attachment.photo?.imageUrlString)!) { image in
                            print("\(String(describing: image?.description)) loaded")
                        }
                    }
                case "link":
                    numberOfItems += 1
                    currentItem += 1
                    cellDescriptor[currentItem] = cellDataDescription(type: .link, photoNum: num)
                case "video":
                    numberOfItems += 1
                    currentItem += 1
                    cellDescriptor[currentItem] = cellDataDescription(type: .video, photoNum: num)
                default:
                    print("default")
                }
            }
        }
        numberOfItems += 1
        currentItem += 1
        cellType[currentItem] = .actions
        cellDescriptor[currentItem] = cellDataDescription(type: .actions)

        cellsDataDesriptions[section] = cellDescriptor
        //print(cellsDataDesriptions)
        
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var plus: Int? = nil
        var vkNew: VKNew
        
        guard let cellDataDescription = cellsDataDesriptions[indexPath.section]?[indexPath.row]
        else { return UICollectionViewCell() }
        
        let isRepost = vkNews[indexPath.section].copyHistory != nil ? true : false
        if isRepost {
            vkNew = (vkNews[indexPath.section].copyHistory?.first!)!
            vkNew.sourceId = vkNew.ownerId
        }
        else {
            vkNew = vkNews[indexPath.section]
        }
        
        switch cellDataDescription.type {
        case .author:
            guard let cell = newsCollection.dequeueReusableCell(withReuseIdentifier: "NewsAuthorCell", for: indexPath) as? NewsAuthorCell
            
            else { return UICollectionViewCell() }
            
            let sourceId = vkNews[indexPath.section].sourceId!
            if sourceId > 0 {
                cell.configure(imageUrlString: profiles[sourceId]?.photoUrlString ?? "none",
                               name: profiles[sourceId]?.fullName ?? "Unknown",
                               date: vkNews[indexPath.section].date)
            }
            else {
                cell.configure(imageUrlString: groups[abs(sourceId)]?.photoUrlString ?? "nonE",
                               name: groups[abs(sourceId)]?.name ?? "Unknown",
                               date: vkNew.date)
            }
            return cell
            
        case .repostAuthor:
            guard let cell = newsCollection.dequeueReusableCell(withReuseIdentifier: "NewsAuthorCell", for: indexPath) as? NewsAuthorCell
            
            else { return UICollectionViewCell() }
            
            let sourceId = vkNew.sourceId!
            if sourceId > 0 {
                cell.configure(imageUrlString: profiles[sourceId]?.photoUrlString ?? "none",
                               name: profiles[sourceId]?.fullName ?? "Unknown",
                               date: vkNews[indexPath.section].date, isRepost: isRepost)
            }
            else {
                cell.configure(imageUrlString: groups[abs(sourceId)]?.photoUrlString ?? "nonE",
                               name: groups[abs(sourceId)]?.name ?? "Unknown",
                               date: vkNew.date, isRepost: isRepost)
            }
            
            
            return cell
        case .text:
            guard let cell = newsCollection.dequeueReusableCell(withReuseIdentifier: "NewsTextCell", for: indexPath) as? NewsTextCell
                
            else { return UICollectionViewCell() }
                
            cell.configure(text: vkNew.text ?? "")
                
            return cell
            
        case let type where type == .photo || type == .link || type == .attachment || type == .attachmentPhoto:
            guard let cell = newsCollection.dequeueReusableCell(withReuseIdentifier: "NewsImageCell", for: indexPath) as? NewsImageCell
            
            else { return UICollectionViewCell() }

            if type == .photo {
                cell.configure(imageUrlString: (vkNew.photos?.items[cellDataDescription.photoNum!].imageUrlString) ?? "None", plus: nil)
            }
            else {
                cell.configure(imageUrlString: (vkNew.attachments?[cellDataDescription.photoNum!].photo?.imageUrlString) ?? "nOne", plus: nil)
            }
            return cell
        case .actions:
            guard let cell = newsCollection.dequeueReusableCell(withReuseIdentifier: "NewsActionsCell", for: indexPath) as? NewsActionsCell
            
            else { return UICollectionViewCell() }
            
            cell.configure(likes: vkNews[indexPath.section].likes,
                           reposts: vkNews[indexPath.section].reposts,
                           tag: indexPath.section)
            
            return cell
        case .video:
            guard let cell = newsCollection.dequeueReusableCell(withReuseIdentifier: "NewsVideoCell", for: indexPath) as? NewsVideoCell
            
            else { return UICollectionViewCell() }
            
            guard let photoNum = cellDataDescription.photoNum,
                  let ownerId = (vkNew.attachments?[photoNum].video?.ownerId),
                  let id = vkNew.attachments?[photoNum].video?.id
            else { return cell}
            var videos = String(ownerId) + "_" + String(id)
            if let accessKey = vkNew.attachments?[photoNum].video?.accessKey {
                videos += "_" + String(accessKey)
            }
            NetworkService.performVkMethod(method: "video.get", with: ["owner_id":String(ownerId), "videos":videos]) { data in
                do {
                    let videos = try JSONDecoder().decode(VKResponse<VKItems<VKVideo>>.self, from: data)
                    let player = videos.response.items[0].player
                    cell.configure(videoUrlString: player ?? "noNe", plus: nil)
                } catch let error {
                    print("error is \(error)")
                }
            }

            
            return cell
        default:
            //break
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setNeedsDisplay()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /*if posts[indexPath.section].isImagesFolded {
            if let celltype = cellsTypes[indexPath.section]?[indexPath.row]{
                if celltype.rawValue == 3 {//image
                    for section in 0 ..< posts.count {
                        posts[section].isImagesFolded = true
                    }
                    posts[indexPath.section].isImagesFolded = false
                    newsCollection.reloadData()
                }
            }
        }
        if posts[indexPath.section].isTextFolded {
            if let celltype = cellsTypes[indexPath.section]?[indexPath.row]{
                if celltype.rawValue == 2 {//text
                    for section in 0 ..< posts.count {
                        posts[section].isTextFolded = true
                    }
                    posts[indexPath.section].isTextFolded = false
                    newsCollection.reloadData()
                }
            }
        }
        newsCollection.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
    */}
}


