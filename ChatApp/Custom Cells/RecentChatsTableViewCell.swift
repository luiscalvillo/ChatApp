//
//  RecentChatsTableViewCell.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/9/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import UIKit

protocol RecentChatsTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var messageCounterLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageCounterBackground: UIView!
    
    var indexPath: IndexPath!
    
    let tapGesture = UITapGestureRecognizer()
    
    var delegate: RecentChatsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageCounterBackground.layer.cornerRadius = messageCounterBackground.frame.width / 2
        
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    // MARK: Generate cell
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.nameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        self.lastMessageLabel.text = recentChat[kLASTMESSAGE] as? String
        self.messageCounterLabel.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messageCounterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageCounterLabel.isHidden = false
            self.messageCounterLabel.isHidden = false
        } else {
            self.messageCounterLabel.isHidden = true
            self.messageCounterLabel.isHidden = true
        }
        
        print(recentChat)
        // Date formating
        var date: Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = dateFormatter().date(from: created as! String)!
            }
        } else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
    }
    
    @objc func avatarTap() {
        print("avatar tap \(indexPath)")
        
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }
    
}
