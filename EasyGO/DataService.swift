//
//  DataService.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/28/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

let roofRef = FIRDatabase.database().reference()

class DataService {
    
    static let dataService = DataService()
    
    private var _BASE_REF       = roofRef
    private var _CHATS_REF      = roofRef.child("chats")
    private var _MESSAGES_REF   = roofRef.child("messages")
    private var _USERS_REF      = roofRef.child("users")
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var currentUser: FIRUser? {
        return FIRAuth.auth()!.currentUser
    }
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    
    var CHATS_REF: FIRDatabaseReference {
        return _CHATS_REF
    }
    
    var MESSAGES_REF: FIRDatabaseReference {
        return _MESSAGES_REF
    }
    
    var USERS_REF: FIRDatabaseReference {
        return _USERS_REF
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var fileURL: String!
    
    //MARK: USER
    func registerUser(name:String, email:String, password:String) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let changeRequest = user?.profileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChangesWithCompletion({ (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            })
            
            let newUser : [String : AnyObject] = [
                "uid":(user?.uid)!,
                "name":name,
                "email":email,
                "profileImage": "",
                "deviceId":"",
                "provider": "email",
                "online": true
            ]
            
            self.USERS_REF.child((user?.uid)!).setValue(newUser)
            
            ProgressHUD.showSuccess("Succeeded.")
            self.startApplication()
        })
    }
    
    func setPhotoUser(data:NSData) {
        
        if let user = FIRAuth.auth()?.currentUser {
            
            let filePath = "profileImage/\(user.uid)"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            self.storageRef.child(filePath).putData(data, metadata: metadata, completion: { (metadata, error) in
                if let error = error {
                    print("Error uploading: \(error.description)")
                    return
                }
                
                self.fileURL = metadata?.downloadURLs![0].absoluteString
                let changeResquestPhoto = user.profileChangeRequest()
                changeResquestPhoto.photoURL = NSURL(string: self.fileURL)
                changeResquestPhoto.commitChangesWithCompletion({ (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    } else {
                        print("Profile updated")
                    }
                })
                
                ProgressHUD.dismiss()
                self.updatePhotoUser(user.uid, imageURL: self.fileURL)
                
            })
        }
    }
    
    func getPhotoUser(imageURL:String, result: (image: UIImage?) -> Void) {
        
        if imageURL.hasPrefix("gs://") {
        
            FIRStorage.storage().referenceForURL(imageURL).dataWithMaxSize(INT64_MAX) { (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                result(image: UIImage.init(data: data!))
            }
            
        } else if let url = NSURL(string: imageURL) {
            
            let downloadQue = dispatch_queue_create("imageDownloadQue", nil)
            
            dispatch_async(downloadQue) { () -> Void in
                
                let data = NSData(contentsOfURL: url)
                let image: UIImage!
                
                if data != nil {
                    image = UIImage(data: data!)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        result(image: image)
                    }
                    
                }
                
            }
            
        }
    }
    
    func fetchUserFromServer(callback: ([User]) -> ()) {
        self.USERS_REF.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists() {
                
                var users: [User] = []
                for item in (snapshot.value?.allValues)! {
                    let user = User.init(snapshot: item as! Dictionary<String, AnyObject>)
                    
                    if user.uid != self.currentUser?.uid {
                        users.append(user)
                    }
                }
                
                ProgressHUD.dismiss()
                callback(users)

            }
            
        })
    }
    
    func getUser(userId:String, result: (user: User) -> ()) {
        
        self.USERS_REF.child(userId).observeSingleEventOfType(.Value, withBlock:  { (snapshot) in
            let user = User.init(snapshot: snapshot.value as! Dictionary<String, AnyObject>)
            result(user: user)
        })
    }
    
    func updatePhotoUser(userId:String, imageURL:String) {
        
        let values = ["profileImage":imageURL]
        
        self.USERS_REF.child(userId).updateChildValues(values, withCompletionBlock: { (error, ref) -> Void in
            
            if let error = error {
                print("Error, couldnt update User: \(error)")
                return
            }
            
        })
        
    }
    
    func searchUser(name:String, callback: ([User], Bool) -> () ) {
        self.USERS_REF.queryOrderedByChild("name").queryStartingAtValue(name).queryEndingAtValue(name+"\u{f8ff}").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            var users: [User] = []
            ProgressHUD.dismiss()
            
            if snapshot.exists() {
                
                for item in (snapshot.value?.allValues)! {
                    let user = User.init(snapshot: item as! Dictionary<String, AnyObject>)
                    
                    if user.uid != self.currentUser?.uid {
                        users.append(user)
                    }
                }
                callback(users, true)
                
            } else {
                callback(users, false)
            }
            
            
        })
        
    }
    
    //MARK: LOGIN
    func logIn(email: String, password:String) {
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            ProgressHUD.showSuccess("Succeeded")
            self.startApplication()
        })
    }
    
    func logInWithGoogle(authentication: GIDAuthentication, userGoogle: GIDGoogleUser) {
        
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user:FIRUser?, error:NSError?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let image = userGoogle.profile.imageURLWithDimension(100).absoluteString
            
            let newUser : [String : AnyObject] = [
                "uid":(user?.uid)!,
                "name":(user?.displayName)!,
                "email":(user?.email)!,
                "profileImage": image!,
                "deviceId":"",
                "provider": "google",
                "online": true
            ]
            
            self.USERS_REF.child((user?.uid)!).setValue(newUser)
            self.startApplication()
        })
    }
    
    func logInWithFacebook() {
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user:FIRUser?, error:NSError?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let newUser : [String : AnyObject] = [
                "uid":(user?.uid)!,
                "name":(user?.displayName)!,
                "email":(user?.email)!,
                "profileImage": (user?.photoURL?.absoluteString)!,
                "deviceId":"",
                "provider": "facebook",
                "online": true
            ]

            self.USERS_REF.child((user?.uid)!).setValue(newUser)
            self.startApplication()
        })
        
    }
    
    func logInWithTwitter(session: TWTRSession) {
        
        let credential = FIRTwitterAuthProvider.credentialWithToken(session.authToken, secret: session.authTokenSecret)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let client = TWTRAPIClient.clientWithCurrentUser()
            let request = client.URLRequestWithMethod("GET", URL: "https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_email": "true", "skip_status": "true"], error: nil)
            
            client.sendTwitterRequest(request, completion: { (response, data, connectionError) in
                if connectionError != nil {
                    print("Error: \(connectionError)")
                    return
                }
                
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    let pictureURL = json.objectForKey("profile_image_url") as! String
                    
                    let newUser : [String : AnyObject] = [
                        "uid":(user?.uid)!,
                        "name":(user?.displayName)!,
                        "email":(user?.email)!,
                        "profileImage": pictureURL,
                        "deviceId":"",
                        "provider": "twitter",
                        "online": true
                    ]
                    
                    self.USERS_REF.child((user?.uid)!).setValue(newUser)
                    self.startApplication()
                    
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                    
                }
                
            })
            
        })
        
    }
    
    func startApplication() {
        
        self.appDelegate.login()
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        if (Backendless.sharedInstance().messagingService.getRegistration().deviceId != nil) {
            
            let deviceId = Backendless.sharedInstance().messagingService.getRegistration().deviceId
            self.registerUserDeviceId(deviceId!)
        }
        
    }
    
    //MARK: LOGOUT
    func logOut() {
        
        changeStatusUser(false)
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewControllerWithIdentifier("viewLogin") as! EGLoginViewController
            UIApplication.sharedApplication().keyWindow?.rootViewController = loginVC
            
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    //MARK: REGISTER DEVICE
    func registerUserDeviceId(token:String) {
        
        if token != "" && currentUser != nil {
            
            self.USERS_REF.child((currentUser?.uid)!).updateChildValues(["deviceId" : token], withCompletionBlock: { (error, ref) -> Void in
                
                if error != nil {
                    print("Error, couldnt register device: \(error?.localizedDescription)")
                }
                
            })
        }
    }
    
    //MARK: CHANGE STATUS
    func changeStatusUser(status:Bool) {
        
        if currentUser != nil {
            
            self.USERS_REF.child((currentUser?.uid)!).updateChildValues(["online" : status], withCompletionBlock: { (error, ref) -> Void in
                
                if error != nil {
                    print("Error, couldnt change status: \(error?.localizedDescription)")
                }
                
            })
        }
    }
    
    //MARK: CHATS
    func createChat(user1:FIRUser, user2:User) -> String {
        
        let userId1:String = user1.uid
        let userId2:String = user2.uid
        
        var chatRoomId:String = ""
        
        let value = userId1.compare(userId2).rawValue
        
        if value < 0 {
            chatRoomId = userId1.stringByAppendingString(userId2)
        } else {
            chatRoomId = userId2.stringByAppendingString(userId1)
        }
        
        let members = [userId1, userId2]
        
        //create recent
        createChatRecent(userId1, chatRoomID: chatRoomId, members: members, withUserUsername: user2.name!, withUserUserId: userId2)
        createChatRecent(userId2, chatRoomID: chatRoomId, members: members, withUserUsername: user1.displayName!, withUserUserId: userId1)
        
        return chatRoomId
    }
    
    func createChatRecent(userId:String, chatRoomID:String, members:[String], withUserUsername:String, withUserUserId:String) {
        
        let query = self.CHATS_REF.queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID)
        query.observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
            
            var createRecent = true
            
            //check with we have a result
            if snapshot.exists() {
                for recent in (snapshot.value?.allValues)! {
                    
                    //if we already have recent with passed userId, we dont create a new one
                    if recent["userId"] as! String == userId {
                        createRecent = false
                    }
                }
            }
            
            if createRecent {
                self.createChatItem(userId, chatRoomID: chatRoomID, members: members, withUserUsername: withUserUsername, withUserUserId: withUserUserId)
            }
            
        })
    }
    
    func createChatItem(userId:String, chatRoomID:String, members:[String], withUserUsername:String, withUserUserId:String) {
        
        let ref = self.CHATS_REF.childByAutoId()
        
        let recentId = ref.key
        let date = dateFormatter().stringFromDate(NSDate())
        
        let recent = ["recentId":recentId, "userId":userId, "chatRoomID":chatRoomID, "members":members, "withUserUsername": withUserUsername, "lastMessage": "", "counter":0, "date":date, "withUserUserId":withUserUserId]
        
        //save to Firebase
        ref.setValue(recent) { (error, ref) in
            if error != nil {
                print("Error creating recent: \(error)")
            }
        }
        
    }
    
    func fetchChatFromServer(userId:String, callback: ([Chat]) -> ()) {
        self.CHATS_REF.queryOrderedByChild("userId").queryEqualToValue(userId).observeEventType(.Value, withBlock: { (snapshot) in
            
            ProgressHUD.dismiss()
            
            if snapshot.exists() {
                
                var chats: [Chat] = []
                let sorted = ((snapshot.value?.allValues)! as NSArray).sortedArrayUsingDescriptors([NSSortDescriptor(key: "date", ascending: false)])
                
                for recent in sorted {
                    
                    let chat = Chat(snapshot: recent as! Dictionary<String, AnyObject>)
                    chats.append(chat)
                }
                
                callback(chats)
            }
            
        })
    }
    
    func clearChatCounter(chatRoomID: String) {
        
        self.CHATS_REF.queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists() {
                
                for recent in (snapshot.value?.allValues)! {
                    
                    if recent.objectForKey("userId") as? String == self.currentUser!.uid {
                        let chat = Chat(snapshot: recent as! Dictionary<String, AnyObject>)
                        self.clearChatCounterItem(chat)
                    }
                    
                }
            }
            
        })
    }
    
    func clearChatCounterItem(chat: Chat) {
        
        self.CHATS_REF.child(chat.recentId).updateChildValues(["counter" : 0], withCompletionBlock: { (error, ref) -> Void in
            
            if error != nil {
                print("Error, couldnt update recents counter: \(error?.localizedDescription)")
            }
            
        })
        
    }
    
    func updateChat(chatRoomID: String, lastMessage: String) {
        
        self.CHATS_REF.queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists() {
                
                for recent in (snapshot.value?.allValues)! {
                    let chat = Chat(snapshot: recent as! Dictionary<String, AnyObject>)
                    self.updateChatItem(chat, lastMessage: lastMessage)
                }
            }
            
        })
        
    }
    
    func updateChatItem(chat: Chat, lastMessage: String) {
        
        let date = dateFormatter().stringFromDate(NSDate())
        var counter = chat.counter!
        
        if chat.userId != currentUser!.uid {
            counter += 1
        }
        
        let values = ["lastMessage" : lastMessage, "counter": counter, "date": date]
        
        self.CHATS_REF.child(chat.recentId).updateChildValues(values as! [NSObject : AnyObject], withCompletionBlock: { (error, ref) -> Void in
            
            if let error = error {
                print("Error, couldnt update recent item: \(error)")
                return
            }
            
        })
        
    }
    
    func restartChat(chat: Chat) {
        
        for userId in chat.members as! [String] {
            
            if userId != currentUser!.uid {
                
                self.createChatRecent(userId, chatRoomID: chat.chatRoomID!, members: chat.members as! [String], withUserUsername: currentUser!.displayName!, withUserUserId: currentUser!.uid)
            }
        }
    }
    
    //MARK: Delete Recent
    func deleteChatItem(chat: Chat) {
        
        self.CHATS_REF.child(chat.recentId!).removeValueWithCompletionBlock { (error, ref) in
            if error != nil {
                print("Error deleting recent item: \(error)")
            }
        }
    }
    
    //MARK: Delete Messages User
    func deleteChatMessages() {
        
        self.CHATS_REF.queryOrderedByChild("userId").queryEqualToValue(currentUser!.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if snapshot.exists() {
                for recent in (snapshot.value?.allValues)! {
                    
                    self.clearChatCounter((recent["chatRoomID"] as? String)!)
                    
                    self._MESSAGES_REF.child((recent["chatRoomID"] as? String)!).removeValueWithCompletionBlock { (error, ref) in
                        if let error = error {
                            print("Error deleting recent message: \(error)")
                            return
                        }
                    }
                }
            }
            
        })
        
    }
    
    //MARK: MESSAGES
    func createNewMessage(chatRoomId: String, item: NSMutableDictionary) {
        
        let reference = self.MESSAGES_REF.child(chatRoomId).childByAutoId()
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) in
            if let error = error {
                print("Error, couldnt send message: \(error.localizedDescription)")
                return
            }
        }
        
        sendPushNotification(chatRoomId, message: (item["message"] as? String)!)
        self.updateChat(chatRoomId, lastMessage: (item["message"] as? String)!)
        
    }
    
    func fetchMessageAddedFromServer(chatRoomId: String, callback:(FIRDataSnapshot) -> ()) {
        self.MESSAGES_REF.child(chatRoomId).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            callback(snapshot)
            ProgressHUD.dismiss()
        })
    }
    
    func fetchMessageValueFromServer(chatRoomId: String, callback:(FIRDataSnapshot) -> ()) {
        self.MESSAGES_REF.child(chatRoomId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            callback(snapshot)
            ProgressHUD.dismiss()
        })
    }
    
    func removeObjserversMessage() {
        self.MESSAGES_REF.removeAllObservers()
    }
    
    
}






