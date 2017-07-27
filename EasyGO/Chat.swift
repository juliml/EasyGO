//
//  Chat.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/28/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation
import UIKit

class Chat {
    
    var recentId: String!
    var userId: String!
    var chatRoomID: String!
    
    var members: NSArray!
    
    var withUserUsername: String!
    var withUserUserId: String!
    
    var lastMessage: String!
    var counter: Int!
    var date: String!
    
    init(snapshot: Dictionary<String, AnyObject>) {
        
        self.recentId = snapshot["recentId"] as! String
        self.userId = snapshot["userId"] as! String
        self.chatRoomID = snapshot["chatRoomID"] as! String
        self.members = snapshot["members"] as! NSArray
        
        self.withUserUsername = snapshot["withUserUsername"] as! String
        self.withUserUserId = snapshot["withUserUserId"] as! String
        
        if let lastMessage = snapshot["lastMessage"] as? String {
            self.lastMessage = lastMessage
        }
        
        self.counter = snapshot["counter"] as! Int
        self.date = snapshot["date"] as! String
    }

    
}