//
//  IncomingMessages.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/16/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    
    // MARK: Create Message
    
    func createMessage(messageDictionary: NSDictionary, chatRooomId: String) -> JSQMessage? {
       
        var message: JSQMessage?
        
        
        let type = messageDictionary[kTYPE] as! String
    
        switch type {
        case kTEXT:
            // create text message
            print("create message")
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRooomId)

        case kPICTURE:
            //
            message = createPictureMessage(messageDictionary: messageDictionary)

        case kVIDEO:
            //
            print("create message")

        case kAUDIO:
            //
            print("create message")

        case kLOCATION:
            //
            print("create message")

        default:
            print("Unknown message type")
        }
        
        
        
        if message != nil {
            return message
        }
        
        return nil
    }
    
    
    // MARK: Create Message Types
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
            
            
        } else {
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    // picture message
    
    func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)
            }
            
            
        } else {
            date = Date()
        }
        
        
        // download image
        
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            if image != nil {
                mediaItem?.image = image!
                self.collectionView.reloadData()
            }
        }
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    // MARK: Helper
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
        /* Longer way
        if senderId == FUser.currentId() {
            return true
        } else {
            return false
        }
 
        */
        
        // shorter way -  same as code above
        return senderId == FUser.currentId()
    }
    
    
}
