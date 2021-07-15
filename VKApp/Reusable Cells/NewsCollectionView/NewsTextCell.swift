//
//  NewsTextCell.swift
//  VKApp
//
//  Created by Denis Kuzmin on 18.04.2021.
//

import UIKit

class NewsTextCell: UICollectionViewCell {

    @IBOutlet weak var text: UITextView!
    

    func configure(text: String) {
        self.text.text = text
        let size = self.text.sizeThatFits(CGSize(width: self.frame.width, height: .infinity))
    }
    
}
