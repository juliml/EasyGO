//
//  OutgoingMessage.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/4/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation

class OutgoingMessage {
    
    //let ref = firebase.child("Message")
    
    let messageDictionary: NSMutableDictionary
    
    init(message: String, senderId: String, senderName: String, date: NSDate, status:String, type:String) {
        
        messageDictionary = ["message" : message,
                             "senderId" : senderId,
                             "senderName" : senderName,
                             "date" : dateFormatter().stringFromDate(date),
                             "status" : status,
                             "type" : type];
        
    }
    
    init(message:String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: NSDate, status:String, type:String) {
        
        messageDictionary = ["message" : message,
                             "latitude" : latitude,
                             "longitude" : longitude,
                             "senderId" : senderId,
                             "senderName" : senderName,
                             "date" : dateFormatter().stringFromDate(date),
                             "status" : status,
                             "type" : type];
        
    }
    
    init(message: String, pictureData: NSData, senderId: String, senderName: String, date: NSDate, status:String, type:String) {
        
        let pic = pictureData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        messageDictionary = ["message" : message,
                             "picture" : pic,
                             "senderId" : senderId,
                             "senderName" : senderName,
                             "date" : dateFormatter().stringFromDate(date),
                             "status" : status,
                             "type" : type];
    }

    
}
