//
//  PicturesCollectionViewCell.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/23/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func generateCell(image: UIImage) {
        
        self.imageView.image = image 
    }
    
}
