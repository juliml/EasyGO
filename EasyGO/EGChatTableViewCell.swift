//
//  EGChatTableViewCell.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/30/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit
import Firebase

class EGChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var nameUser: UILabel!
    
    @IBOutlet weak var labelStatusUser: UILabel!
    @IBOutlet weak var imageStatusUser: UIImageView!
    
    @IBOutlet weak var timeMessenger: UILabel!
    @IBOutlet weak var numberMessenger: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(chat: Chat) {
        
        self.imageUser.layer.cornerRadius = self.imageUser.frame.size.height/2
        self.imageUser.layer.masksToBounds = true
        self.imageUser.layer.borderWidth = 0
        
        self.imageUser.image = UIImage(named: "avatar")
        
        //get user and download avatar
        let withUserId = chat.withUserUserId!
        
        DataService.dataService.getUser(withUserId) { (user:User) in
            
            if user.profileImage != nil {
                
                DataService.dataService.getPhotoUser(user.profileImage, result: { (image) in
                    self.imageUser.image = image
                })
                
                if let online = user.online {
                    if online {
                        self.labelStatusUser.text = "Online"
                        self.imageStatusUser.image = UIImage(named:"icon_on")
                    } else {
                        self.labelStatusUser.text = "Offline"
                        self.imageStatusUser.image = UIImage(named:"icon_off")
                    }
                }

            } else {
                //no user is signed in
            }
        }
        
        self.nameUser.text = chat.withUserUsername!
        self.numberMessenger.text = ""
        
        let counter = chat.counter
        
        if counter != 0 && counter != nil {
            self.numberMessenger.text = "\(counter) New"
        }
        
        let date = dateFormatter().dateFromString(chat.date!)
        let seconds = NSDate().timeIntervalSinceDate(date!)
        self.timeMessenger.text = timeElapsed(seconds)
        
    }
    
    func timeElapsed(seconds: NSTimeInterval) -> String {
        
        let elapsed: String?
        
        if (seconds < 60) {
            elapsed = "Now"
            
        } else if (seconds < 60 * 60) {
            let minutes = Int(seconds / 60)
            
            var minText = "min"
            if minutes > 1 {
                minText = "mins"
            }
            elapsed = "\(minutes) \(minText)"
            
        } else if (seconds < 24 * 60 * 60) {
            let hours = Int(seconds / (60 * 60))
            
            var hourText = "hour"
            if hours > 1 {
                hourText = "hours"
            }
            elapsed = "\(hours) \(hourText)"
            
        } else {
            let days = Int(seconds / (24 * 60 * 60))
            
            var dayText = "day"
            if days > 1 {
                dayText = "days"
            }
            elapsed = "\(days) \(dayText)"
        }
        
        return elapsed!
    }

}
