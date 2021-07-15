//
//  SaveGroupsToRealmOperation.swift
//  VKApp
//
//  Created by Denis Kuzmin on 15.07.2021.
//

import Foundation

class SaveGroupsToRealmOperation: AsyncOperation {
    
    override func main() {
        guard let parsingGroupsOperation = dependencies.first as? ParsingGroupsOperation,
              let groups = parsingGroupsOperation.groups
        else { return }
        do {
            try RealmService.save(items: groups)
        }
        catch let error {
            print("Error in SaveGroupsToRealmOperation: \(error.localizedDescription)")
        }
    }
}
