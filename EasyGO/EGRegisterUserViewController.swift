//
//  EGRegisterUserViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/14/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit

class EGRegisterUserViewController: EGBaseViewController {

    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    @IBOutlet weak var fieldRepPassword: UITextField!
    
    var avatarImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paddingForFirst = UIView(frame: CGRectMake(0, 0, 30, self.fieldPassword.frame.height))
        self.fieldName.leftView = paddingForFirst
        self.fieldName.leftViewMode = UITextFieldViewMode .Always
        
        let paddingForSecond = UIView(frame: CGRectMake(0, 0, 30, self.fieldEmail.frame.height))
        self.fieldEmail.leftView = paddingForSecond
        self.fieldEmail.leftViewMode = UITextFieldViewMode .Always
        
        let paddingForThird = UIView(frame: CGRectMake(0, 0, 30, self.fieldPassword.frame.height))
        self.fieldPassword.leftView = paddingForThird
        self.fieldPassword.leftViewMode = UITextFieldViewMode .Always
        
        let paddingForFourth = UIView(frame: CGRectMake(0, 0, 30, self.fieldRepPassword.frame.height))
        self.fieldRepPassword.leftView = paddingForFourth
        self.fieldRepPassword.leftViewMode = UITextFieldViewMode .Always
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func registerUser(sender: AnyObject) {

        guard let name = self.fieldName.text where !name.isEmpty, let email = self.fieldEmail.text where !email.isEmpty, let password = self.fieldPassword.text where !password.isEmpty, let repassword = self.fieldRepPassword.text where !repassword.isEmpty else {
            return
        }
        
        if isValidEmail(email) && password.characters.count > 5 && password == repassword {
            
            ProgressHUD.show("Please wait", interaction: false)
            DataService.dataService.registerUser(name, email: email, password: password)
            
        } else {
            showAlert(self, description: "Complete the fields")
        }

    }
    
    @IBAction func closeRegister(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
