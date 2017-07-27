//
//  PushNotifications.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/11/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation
import FirebaseMessaging

func sendPushNotification(chatRoomId: String, message:String) {
    
    DataService.dataService.CHATS_REF.queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
        
        if snapshot.exists() {
            
            let recents = snapshot.value?.allValues
            
            if let recent = recents?.first {
                sendPush((recent["members"] as? [String])!, message: message)
            }
        }
        
    })
}

func sendPush(members:[String], message:String) {
    
    let message = (DataService.dataService.currentUser?.displayName)! + ": " + message
    let withUserId = withUserIdFromArray(members)!
    
    DataService.dataService.getUser(withUserId) { (user) in
        
        let withUser = user as User
        sendPushMessage(withUser, message: message)
        
    }
}

func sendPushMessage(toUser: User, message:String) {
    
    if let deviceId = toUser.deviceId {

        let deliveryOptions = DeliveryOptions()
        deliveryOptions.pushSinglecast = [deviceId]
        deliveryOptions.pushPolicy(PUSH_ONLY)
        
        let publishOptions = PublishOptions()
        publishOptions.assignHeaders(["ios-alert" : "\(DataService.dataService.currentUser!.displayName!) enviou uma mensagem!", "ios-badge" : "1", "ios-sound" : "defauld"])
        
        Backendless.sharedInstance().messagingService.publish("default", message: message, publishOptions: publishOptions, deliveryOptions: deliveryOptions)
    }
    
}

func withUserIdFromArray(users: [String]) -> String? {
    
    var id:String?
    
    for user in users {
        if user != DataService.dataService.currentUser?.uid {
            id = user
        }
    }
    
    return id
}