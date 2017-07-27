//
//  IncomingMessage.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/5/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary["type"] as? String
        
        if type == "text" {
            //create text message
            message = createTextMessage(dictionary)
        }
        if type == "picture" {
            //create picture message
            message = createPictureMessage(dictionary)
        }
        if type == "location" {
            //create location message
        }
        
        if let mes = message {
            return mes
        }
        
        return nil
        
    }
    
    func createTextMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    func createPictureMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        
        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem.appliesMediaViewMaskAsOutgoing = returnedOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image) in
            mediaItem.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func returnedOutgoingStatusFromUser(senderId: String) -> Bool {
        
        if let user = DataService.dataService.currentUser {
            
            if senderId == user.uid {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }

    }
    
    func imageFromData(item: NSDictionary, result: (image: UIImage?) -> Void) {
        
        var image: UIImage?
        
        let decodedData = NSData(base64EncodedString: (item["picture"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))
        
        image = UIImage(data: decodedData!)
        
        result(image: image)
    }
    
}









