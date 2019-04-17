//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/11/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {
    
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    
    var maxMessageNumber = 0
    var minMessageNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    
    var messages: [JSQMessage] = []
    // save messages as NSDictionary too
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    var initialLoadComplete = false
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    

      // Fix for iPhone X
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
     // end of iPhone X
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // load messages
        loadMessages()
        
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()?.firstname
        
        // Fix for iPhone X
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint

        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        // end of iPhone X
        
        // custom send button alway on
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        
        // EDITED FILE IN JQQINPUTTOOLBAR.M
        // BOOL hasText = TRUE; // REMOVE TRUE - LUIS

    }
    
    // MARK: JSQMessages Delegate Functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            print("camera")
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Libary", style: .default) { (action) in
            
            print("photo libray")
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            
            print("video library")
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            
            print("share location")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        
        }
        
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        
        // For iPad to not crash
        if ( UI_USER_INTERFACE_IDIOM() == .pad) {
            if let currentPopoverPresentationController = optionMenu.popoverPresentationController {
                currentPopoverPresentationController.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverPresentationController.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverPresentationController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        } else {
            print("audio message")
        }
    }
    
    
    
    // MARK: Send Messages
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        
        var outgoingMessage: OutgoingMessages?
        let currentUser = FUser.currentUser()!
        
        // text message
        
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        // cleans message field
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    
    // MARK: Load Messages
    
    func loadMessages() {
        // get last 11 messages
        
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                // initial loading is done
                self.initialLoadComplete = true
                // listen for new chats
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
       
            // remove bad messages
            
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
                 print(sorted)
            // insert messages
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            
            print("we have \(self.messages.count) messages loaded")
            self.initialLoadComplete = true
            
            // get picture messages
            
            // get old messages in background
            
            // start listening for new chats
        }
    }
    
    // MARK: InsertMessages
    
    func insertMessages() {
        maxMessageNumber = loadedMessages.count - loadedMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in minMessageNumber ..< maxMessageNumber {
            let messageDictionary = loadedMessages[i]
            // insert message
            insertInitialLoadMessages(messageDictionary: messageDictionary)
      
            loadedMessagesCount += 1
        }
    
        self.showLoadEarlierMessagesHeader = loadedMessagesCount != loadedMessages.count
    }

  
    
    func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool {
        // check if incoming
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        if (messageDictionary[kSENDERID] as! String ) != FUser.currentId() {
            // update message status
            
        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRooomId: chatRoomId)
        
        if message != nil {
            objectMessages.append(messageDictionary)
            messages.append(message!)
            print("message is nil")
        
        }
        print("insertIntialLoadMessages() called")
        return isIncoming(messageDictionary: messageDictionary)
        
    }
    
    // MARK: IBActions
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: Custom Send Button
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
            updateSendButton(isSend: false)
        }
    }
    
    
    func updateSendButton(isSend: Bool) {
        
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
             self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    // MARK: Helper functions
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        
        for message in tempMessages {
        
            if message[kTYPE] != nil {
                
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    // remove the message
                    
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.index(of: message)!)

            }
        }
        
        return tempMessages
    }
 
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        } else {
            return true
        }
    }

}
