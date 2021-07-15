//
//  ParsingGroupsOperation.swift
//  VKApp
//
//  Created by Denis Kuzmin on 15.07.2021.
//

import Foundation

class ParsingGroupsOperation: AsyncOperation {
    var groups: [VKRealmGroup]?
    
    override func main() {
        guard let getGroupsOperation = dependencies.first as? GetGroupsOperation,
              let data = getGroupsOperation.data
        else { return }
        
        do {
            let vkResponse = try JSONDecoder().decode(VKResponse<VKItems<VKRealmGroup>>.self, from: data)
            self.groups = vkResponse.response.items
        }
        catch let error {
            print("Error in ParsingGroupsOperation: \(error.localizedDescription)")
        }
        self.state = .finished
    }
}
