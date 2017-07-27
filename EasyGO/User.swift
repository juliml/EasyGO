//
//  User.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/28/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    var uid: String!
    var name: String!
    var email: String!
    var profileImage: String!
    var provider: String!
    var deviceId: String!
    var online: Bool!
    
    init(snapshot: Dictionary<String, AnyObject>) {
        
        self.uid = snapshot["uid"] as! String
        self.name = snapshot["name"] as! String
        self.email = snapshot["email"] as! String
        
        if let profileImage = snapshot["profileImage"] as? String {
            self.profileImage = profileImage
        }
        
        if let deviceId = snapshot["deviceId"] as? String {
            self.deviceId = deviceId
        }

        self.provider = snapshot["provider"] as! String
        self.online = snapshot["online"] as! Bool

    }
    
    
}