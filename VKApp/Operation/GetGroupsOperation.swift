//
//  GetGroupsOperation.swift
//  VKApp
//
//  Created by Denis Kuzmin on 15.07.2021.
//

import Foundation

class GetGroupsOperation: AsyncOperation {
    var data: Data?
    
    override func main() {
        
        let parameters = [
            "extended" : "1",
            "user_id" : String(Session.Instance.userId),
        ]
        
        NetworkService.performVkMethod(method: "groups.get",
                                       with: parameters,
                                       token: Session.Instance.token) {[weak self] data in
            self?.data = data
            self?.state = .finished
            
        }
    }
    
}
