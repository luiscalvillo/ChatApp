//
//  PhotoMediaItem.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/17/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class PhotoMediaItem: JSQPhotoMediaItem {
    override func mediaViewDisplaySize() -> CGSize {
        
        let defaultSize: CGFloat = 256
        
        var thumbSize: CGSize = CGSize(width: defaultSize, height: defaultSize)
        
        // check if image is portrait or landscape
        if self.image != nil && self.image.size.height > 0 && self.image.size.width > 0 {
            let aspect: CGFloat = self.image.size.width / self.image.size.height
            
            if self.image.size.width > self.image.size.height {
                // landscape
                thumbSize = CGSize(width: defaultSize, height: defaultSize / aspect)
            } else {
                
                thumbSize = CGSize(width: defaultSize * aspect, height: defaultSize)

            }
            
        }
        
        return thumbSize
    }
}
