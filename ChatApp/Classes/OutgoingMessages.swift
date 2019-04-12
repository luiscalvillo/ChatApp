//
//  OutgoingMessages.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/11/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import Foundation

class OutgoingMessages {
    
    let messageDictionary: NSMutableDictionary
    
    
    
    
    // MARK: Initializers
    
    // Text Message
    
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
        
        
        
    }
    
    
    // MARK: Send Message
    
    func sendMessage(chatRoomID: String, messageDictionary: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        
        let messageId = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageId
        
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomID).document(messageId).setData(messageDictionary as! [String : Any])
        }
        
        // update recent chat
        
        // send push notifications 
    }
    
    
    
    
    
}
