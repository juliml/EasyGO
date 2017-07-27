//
//  EGChooseUserViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/30/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInvites
import FBSDKShareKit
import MessageUI

protocol EGChooseUserDelegate {
    func createChatRoom(withUser: User)
}

class EGChooseUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FIRInviteDelegate, FBSDKAppInviteDialogDelegate, MFMailComposeViewControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableUsers: UITableView!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var searchFriends: UISearchBar!
    
    var delegate : EGChooseUserDelegate!
    var users: [User] = []
    var currentUser :User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = DataService.dataService.currentUser {
            
            DataService.dataService.getUser(user.uid, result: { (user) in
                self.currentUser = user
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.clearColor()
        
        let user = users[indexPath.row] as User
        cell.textLabel!.text = user.name
        cell.detailTextLabel!.text = user.email
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let user = users[indexPath.row]
        delegate.createChatRoom(user)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: IBAction
    
    @IBAction func cancelChoose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func inviteFriends(sender: AnyObject) {
        
        if currentUser?.provider == "facebook" {
            self.inviteFriendsFacebook()
        } else if currentUser?.provider == "google" {
            self.inviteFriendsGoogle()
        } else {
            self.inviteFriendsContact()
        }

    }
    
    //MARK: INVITE EMAIL
    func inviteFriendsContact() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            //mail.setToRecipients(["paul@hackingwithswift.com"])
            mail.setSubject("Try EasyGo Messenger")
            mail.setMessageBody("<p>Download this new messaging app.</p><a href=\"http://www.easygomessenger.com/\">Install!</a>\n", isHTML: true)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: INVITE GOOGLE
    func inviteFriendsGoogle() {
        
        if let invite = FIRInvites.inviteDialog() {
            invite.setInviteDelegate(self)
            
            invite.setMessage("Try this out!")
            invite.setTitle("Invite Friends")
            invite.setDeepLink("app_url")
            invite.setCallToActionText("Install!")
            //invite.setCustomImage("http://julianalacerda.com/img/Icon-easyGo.png")
            invite.open()
        }
    }
    
    func inviteFinishedWithInvitations(invitationIds: [AnyObject], error: NSError?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
        } else {
            print("Invitations sent")
        }
    }
    
    //MARK: FBSDKAppInviteDialogDelegate
    func inviteFriendsFacebook()
    {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string: "https://fb.me/1195731427144295")
        content.appInvitePreviewImageURL = NSURL(string: "http://julianalacerda.com/img/Icon-easyGo.png")
        FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
        
    }

    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("invitation made")
    }
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print("error made")
    }
    
    //MARK: Search Delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {

        self.searchFriends.showsCancelButton = true
        let uiButton = self.searchFriends.valueForKey("cancelButton") as! UIButton
        uiButton.setTitle("Cancel", forState: UIControlState.Normal)
        
        self.tableUsers.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {

        self.users = []
        
        self.searchFriends.endEditing(true)
        self.searchFriends.showsCancelButton = false
        self.searchFriends.text = ""
        self.searchFriends.resignFirstResponder()
        
        self.tableUsers.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        self.searchFriends.showsCancelButton = false
        
        ProgressHUD.show("Loading...", interaction: false)
        DataService.dataService.searchUser(searchBar.text!) { (objects, exist) in
            
            if exist {
                self.users = objects
            } else {
                self.users = []
                showAlert(self, description: "User not found!")
            }
            
            self.tableUsers.reloadData()
        }
        
        self.searchFriends.resignFirstResponder()
    }

}

