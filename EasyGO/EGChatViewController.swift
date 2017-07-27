//
//  EGChatViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/4/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController
import IDMPhotoBrowser

class EGChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {

    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    
    var withUser: User?
    var chat: Chat?
    
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 182/255, green: 191/255, blue: 196/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 182/255, green: 191/255, blue: 196/255, alpha: 1.0))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EGChatViewController.dismissKeyboard(_:)))
        tapGestureRecognizer.delegate = self
        collectionView?.addGestureRecognizer(tapGestureRecognizer)
        
        if let user = DataService.dataService.currentUser {
            
            self.senderId = user.uid
            self.senderDisplayName = user.displayName
            
            if withUser?.uid == nil {
                
                getWithUserFromChat(chat!, result: { (withUser) in
                    self.withUser = withUser
                    self.title = withUser.name
                    self.getAvatars()
                })
                
            } else {
                
                self.title = withUser!.name
                self.getAvatars()
            }
            
            //load firebase messages
            self.loadMessages()
        }

    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    func dismissKeyboard(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: JSQMessages DataSource
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        if cell.textView != nil {
            
            if data.senderId == self.senderId {
                cell.textView!.textColor = UIColor.whiteColor()
            } else {
                cell.textView!.textColor = UIColor.whiteColor()
            }
        }
        
        return cell
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == self.senderId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        let status = message["status"] as! String
        
        if indexPath.row == (messages.count - 1) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if outgoing(objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    //MARK: JSQMessages Delegate
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if text != ""{
            sendMessage(text, date: date, picture: nil, location: nil)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) in
            camera.presentPhotoCamera(self, canEdit: false)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) in
            camera.presentPhotoLibrary(self, canEdit: false)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) in
            print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: Send Message
    func sendMessage(text: String?, date: NSDate, picture: UIImage?, location:String? ) {
        
        var outgoingMessage = OutgoingMessage?()
        
        if let text = text {
            //send text message
            outgoingMessage = OutgoingMessage(message: text, senderId: self.senderId!, senderName: self.senderDisplayName!, date: date, status: "Delivered", type: "text")
        }
        
        if let pic = picture {
            //send picture message
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            
            outgoingMessage = OutgoingMessage(message: "Picture", pictureData: imageData!, senderId: self.senderId!, senderName: self.senderDisplayName!, date: date, status: "Delivered", type: "picture")
        }
        
        /*if let loc = location {
            //send location message
        }*/
        
        //play message sent sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        DataService.dataService.createNewMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
        
    }
    
    //MARK: Load Messages
    func loadMessages() {
        
        ProgressHUD.show("Loading...")
        
        DataService.dataService.fetchMessageAddedFromServer(chatRoomId) { (snapshot) in
            
            if snapshot.exists() {
                
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {
                    let incoming = self.insertMessage(item)
                    
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessageAnimated(true)
                    
                } else {
                    self.loaded.append(item)
                }
            }
        }
        
        DataService.dataService.fetchMessageValueFromServer(chatRoomId) { (snapshot) in
            
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComplete = true
        }

    }
    
    func insertMessages() {
        
        for item in loaded {
            //create message
            insertMessage(item)
        }
    }
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        if self.senderId == item["senderId"] as! String {
            return false
        } else {
            return true
        }
    }
    
    func outgoing(item: NSDictionary) -> Bool {
        
        if self.senderId == item["senderId"] as! String {
            return true
        } else {
            return false
        }
    }
    
    //MARK: Load Avatars
    func getAvatars() {
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
        
        //downloads avatars
        let currentUser = DataService.dataService.currentUser
        if currentUser!.photoURL != nil {
            DataService.dataService.getPhotoUser((currentUser!.photoURL?.absoluteString)!) { (image) in
                let imageData = UIImageJPEGRepresentation(image!, 1.0)
                self.avatarImageUser((currentUser?.uid)!, imageData: imageData!)
            }
        }
        
        DataService.dataService.getPhotoUser((withUser?.profileImage)!) { (image) in
            let imageData = UIImageJPEGRepresentation(image!, 1.0)
            self.avatarImageUser((self.withUser?.uid)!, imageData: imageData!)
        }
        
        //create avatars
        createAvatars(self.avatarImagesDictionary)
    }
    
    func getWithUserFromChat(chat: Chat, result: (withUser: User) -> Void) {
        
        let withUserId = chat.withUserUserId
        
        DataService.dataService.getUser(withUserId) { (user:User) in
            result(withUser: user)
        }

    }
    
    func createAvatars(avatars: NSMutableDictionary?) {
        
        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:"avatar"), diameter: 70)
        var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named:"avatar"), diameter: 70)
        
        if let avat = avatars {
            if let currentAvatarImage = avat.objectForKey(self.senderId) {
                
                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: currentAvatarImage as! NSData), diameter: 70)
                self.collectionView?.reloadData()
            }
        }
        
        if let avat = avatars {
            if let withtAvatarImage = avat.objectForKey(withUser!.uid) {
                
                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: withtAvatarImage as! NSData), diameter: 70)
                self.collectionView?.reloadData()
            }
        }
        
        avatarDictionary = [self.senderId: currentUserAvatar, withUser!.uid: withUserAvatar]
        
    }
    
    func avatarImageUser(userId:String, imageData: NSData) {
        
         if self.avatarImagesDictionary != nil {
            self.avatarImagesDictionary?.removeObjectForKey(userId)
            self.avatarImagesDictionary?.setObject(imageData, forKey: userId)
         } else {
            self.avatarImagesDictionary = [userId: imageData]
         }
     
        self.createAvatars(self.avatarImagesDictionary)
     
    }
    
    //MARK: JSQDelegate Functions
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            
            let message = messages[indexPath.row]
            let mediaItem = message.media as! JSQPhotoMediaItem
            
            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
            
        }
    }
    
    //MARK: UIImagePickerController Functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.sendMessage("", date: NSDate(), picture: image, location: nil)
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        DataService.dataService.clearChatCounter(chatRoomId)
        DataService.dataService.removeObjserversMessage()
        
        if (self.isMovingFromParentViewController()) {
            UIDevice.currentDevice().setValue(Int(UIInterfaceOrientation.Portrait.rawValue), forKey: "orientation")
        }
    }
    
    func canRotate() -> Void {}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
