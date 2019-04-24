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
            message = createVideoMessage(messageDictionary: messageDictionary)

        case kAUDIO:
            //
            message = createAudioMessage(messageDictionary: messageDictionary)

        case kLOCATION:
            //

            message = createLocationMessage(messageDictionary: messageDictionary)

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
    /* my code
    // video
    func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
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
        
        
        
        let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
        
        // download video
        
        downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            
            mediaItem.status = kSUCCESS
            mediaItem.fileUrl = url
            
            print("video downloaded")
            
            // get thumbNail
         
            imageFromData(pictureData: messageDictionary[kPICTURE] as! String, withBlock: { (image) in
              print("imagefromdata called")
                if image != nil {
                    mediaItem.image = image!
                    self.collectionView.reloadData()
                    
                    print("image is not nil")

                }
            })
        
            self.collectionView.reloadData()
        }
 
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    */
    
    // ichat code
    
    
    func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
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
        
        let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
        
        
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
        
        
        //download video
        
        downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, fileName) in
            
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            
            mediaItem.status = kSUCCESS
            mediaItem.fileUrl = url
            
            imageFromData(pictureData: messageDictionary[kPICTURE] as! String, withBlock: { (image) in
                
                if image != nil {
                    mediaItem.image = image!
                    self.collectionView.reloadData()
                }
            })
            
            self.collectionView.reloadData()
        }
        
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    func createAudioMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
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


        let audioItem = JSQAudioMediaItem(data: nil)
        audioItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        let audioMessage = JSQMessage(senderId: userId!, displayName: name!, media: audioItem)
        
        
        //download audio
        
        downloadAudio(audioUrl: messageDictionary[kAUDIO] as! String) { (fileName) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: fileName))
            
            let audioData = try? Data(contentsOf: url as URL)
            audioItem.audioData = audioData
            
            self.collectionView.reloadData()
        }
        
        return audioMessage!
    }
    
    
    // create location message
    
    func createLocationMessage(messageDictionary: NSDictionary) -> JSQMessage {
        
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
        let latittude = messageDictionary[kLATITUDE] as? Double
        let longitude = messageDictionary[kLONGITUDE] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        let location =  CLLocation(latitude: latittude!, longitude: longitude!)
        
        mediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
            
        })
        
        return JSQMessage(senderId: userId!, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    
    
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
