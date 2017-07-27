//
//  EGLoginViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/7/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import TwitterKit

class EGLoginViewController: EGBaseViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var signInTwitter: UIButton!
    @IBOutlet weak var signInFacebook: UIButton!
    
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paddingForFirst = UIView(frame: CGRectMake(0, 0, 60, self.fieldEmail.frame.size.height))
        self.fieldEmail.leftView = paddingForFirst
        self.fieldEmail.leftViewMode = UITextFieldViewMode .Always
        
        let imageViewFirst = UIImageView();
        let imageFirst = UIImage(named: "icon_user");
        imageViewFirst.image = imageFirst;
        imageViewFirst.frame = CGRect(x: 20, y: 12, width: 25, height: 25)
        self.fieldEmail.addSubview(imageViewFirst)
        
        let paddingForSecond = UIView(frame: CGRectMake(0, 0, 60, self.fieldPassword.frame.height))
        self.fieldPassword.leftView = paddingForSecond
        self.fieldPassword.leftViewMode = UITextFieldViewMode .Always
        
        let imageViewSecond = UIImageView();
        let imageSecond = UIImage(named: "icon_password");
        imageViewSecond.image = imageSecond;
        imageViewSecond.frame = CGRect(x: 20, y: 12, width: 24, height: 24)
        self.fieldPassword.addSubview(imageViewSecond)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    

    //MARK: Login with Twitter
    @IBAction func loginWithTwitter(sender: AnyObject) {
        
        Twitter.sharedInstance().logInWithMethods([.WebBased]) { (session, error) in
            if session != nil {
                DataService.dataService.logInWithTwitter(session!)
            }
        }

    }
    
    //MARK: Login with Facebook
    @IBAction func loginWithFacebook(sender: AnyObject) {
        
        
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile", "email", "user_friends"], fromViewController: self, handler: { (facebookResult, facebookError) -> Void in
        
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            
            } else {
                DataService.dataService.logInWithFacebook()
            }
        
        })
        
    }

    //MARK: Login with Google
    @IBAction func loginWithGoogle(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    //MARK: Login with Email
    @IBAction func loginWithEmail(sender: AnyObject) {
        
        guard let email = self.fieldEmail.text where !email.isEmpty, let password = self.fieldPassword.text where !password.isEmpty else {
            ProgressHUD.showError("Email and Password can't be empty")
            return
        }
        
        ProgressHUD.show("Signing in...")
        DataService.dataService.logIn(email, password: password)
    }
    
    //MARK: Register new User
    @IBAction func registerUser(sender: AnyObject) {
        
        let viewRegister:EGRegisterUserViewController = self.storyboard!.instantiateViewControllerWithIdentifier("viewRegister") as! EGRegisterUserViewController;

        let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        viewRegister.modalTransitionStyle = modalStyle
        
        self.presentViewController(viewRegister, animated: true, completion:nil)
        
    }
    
    //MARK: GoogleSingIn Delegate
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        print(user.authentication)
        DataService.dataService.logInWithGoogle(user.authentication, userGoogle: user)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
