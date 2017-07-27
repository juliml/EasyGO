//
//  EGListChatsViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/14/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit
import Firebase

class EGListChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EGChooseUserDelegate {

    @IBOutlet weak var tableChats: UITableView!
    
    var recents : [Chat] = []
    var refreshControl: UIRefreshControl!
    private let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.setNavigationBarHidden(false, animated: false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(EGListChatsViewController.loadRecents), forControlEvents: UIControlEvents.ValueChanged)
        self.tableChats.addSubview(refreshControl)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(EGListChatsViewController.appMovedToBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        loadRecents()
        
        if !isFirstRun() {
            
            let passcodeVC: PasscodeLockViewController
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
            
            presentViewController(passcodeVC, animated: true, completion: nil)
            
            loadUserFirstRun()
        }

    }
    
    func appMovedToBackground() {
        
        self.navigationController?.popViewControllerAnimated(false)
        DataService.dataService.deleteChatMessages()

    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EGChatTableViewCell
        
        cell.backgroundColor = UIColor.clearColor()
        
        let chat = recents[indexPath.row]
        cell.bindData(chat)
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //restart recent chat for users
        let chat = recents[indexPath.row] as Chat
        DataService.dataService.restartChat(chat)
        
        performSegueWithIdentifier("recentToChat", sender: indexPath)
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let chat = recents[indexPath.row] as Chat
        
        //remove recent from the array
        recents.removeAtIndex(indexPath.row)
        
        //delete recent from the firebase
        DataService.dataService.deleteChatItem(chat)
        
        self.tableChats.reloadData()
    }

    //MARK: IBActions
    
    @IBAction func startNewChat(sender: AnyObject) {
        performSegueWithIdentifier("chatsToNewChat", sender: self)
        
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatsToNewChat" {
            let chooseVC = segue.destinationViewController as! EGChooseUserViewController
            chooseVC.delegate = self
        }
        
        if segue.identifier == "recentToChat" {
            let indexPath = sender as! NSIndexPath
            let chatVC = segue.destinationViewController as! EGChatViewController
            
            let chat = recents[indexPath.row]
            chatVC.chat = chat
            
            chatVC.chatRoomId = chat.chatRoomID
        }
    }
    
    
    //MARK: ChooseUserDelegate
    func createChatRoom(withUser: User) {

        if let user = DataService.dataService.currentUser {
            
            let chatVC = EGChatViewController()
            navigationController?.pushViewController(chatVC, animated: true)
            
            chatVC.withUser = withUser
            chatVC.chatRoomId = DataService.dataService.createChat(user, user2: withUser)
        }

    }
    
    //MARK: Load Recents Chats Firebase
    func loadRecents() {
        
        if let user = DataService.dataService.currentUser {
            
            ProgressHUD.show("Loading...", interaction: false)
            DataService.dataService.fetchChatFromServer(user.uid, callback: { (objects) in
                
                self.recents.removeAll()
                self.recents = objects
                
                if self.refreshControl.refreshing {
                    self.refreshControl.endRefreshing()
                }
                
                self.tableChats.reloadData()
            })

        }
        
    }
    
}





