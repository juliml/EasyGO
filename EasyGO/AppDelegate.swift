//
//  AppDelegate.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/1/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseInvites

import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var backendless = Backendless.sharedInstance()
    
    //MARK: Present Passcode
    lazy var passcodeLockPresenter: PasscodeLockPresenter = {
        
        let configuration = PasscodeLockConfiguration()
        let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration)
        
        return presenter
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //BuddyBuild
        BuddyBuildSDK.setup()
        
        //Backendless
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        
        //Firebase
        FIRApp.configure()
        
        //Google
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //Twitter
        let info:NSDictionary = NSBundle.mainBundle().infoDictionary!
        Twitter.sharedInstance().startWithConsumerKey(info.objectForKey("consumerKey") as! String, consumerSecret: info.objectForKey("consumerSecret") as! String)
        
        //LOGIN USER
        login()
        

        //Register PushNotification
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        if let launchOptions = launchOptions as? [String: AnyObject] {
            if let notificationDictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject] {
                self.application(application, didReceiveRemoteNotification: notificationDictionary)
            }
        }
        
        //Config NavBar
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor(red: 161/255.0, green: 161/255.0, blue: 161/255.0, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 161/255.0, green: 161/255.0, blue: 161/255.0, alpha: 1.0)]

        return true
    }
    
    //MARK: LoginAuth
    func application(application: UIApplication,
                     openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
     
        if let invite = FIRInvites.handleURL(url, sourceApplication:sourceApplication, annotation:annotation) as? FIRReceivedInvite {
            let matchType =
                (invite.matchType == FIRReceivedInviteMatchType.Weak) ? "Weak" : "Strong"
            print("Invite received from: \(sourceApplication) Deeplink: \(invite.deepLink)," +
                "Id: \(invite.inviteId), Type: \(matchType)")
            return true
        }
        
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        
    }
    
    
    func application(application: UIApplication,
                     openURL url: NSURL, options: [String: AnyObject]) -> Bool {
        
        if (GIDSignIn.sharedInstance().handleURL(url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])) {
            return true
        
        } else if (FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])) {
            return true
            
        } else {
            
            return self.application(application, openURL: url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String, annotation: "")
        }

    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        DataService.dataService.changeStatusUser(false)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (application.applicationIconBadgeNumber > 0) {
            passcodeLockPresenter.presentPasscodeLock()
        }
        
        DataService.dataService.changeStatusUser(true)
        //connectToFcm()
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Register Device Token
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        backendless.messagingService.registerDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        if application.applicationState == UIApplicationState.Active {
            // app was already active
        } else {
            // push handling
            passcodeLockPresenter.presentPasscodeLock()
        }
        
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("couldnt register for notifications : \(error.localizedDescription)")
    }
    
    //MARK: Orientation
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(window?.rootViewController) {
            if (rootViewController.respondsToSelector(Selector("canRotate"))) {
                // Unlock landscape view orientations for this view controller
                return .AllButUpsideDown;
            }
        }
        
        // Only allow portrait (standard behaviosetAPNSToken:devTokenur)
        return .Portrait;
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKindOfClass(UITabBarController)) {
            return topViewControllerWithRootViewController((rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKindOfClass(UINavigationController)) {
            return topViewControllerWithRootViewController((rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
    //MARK: Login
    func login() {
        
        if (FIRAuth.auth()!.currentUser) != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationChats = storyboard.instantiateViewControllerWithIdentifier("ChatNavigation") as! UINavigationController
            
            window?.rootViewController = navigationChats
            
        }
    }
}

