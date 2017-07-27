//
//  EGBaseViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/16/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit

class EGBaseViewController: UIViewController, UITextFieldDelegate {

    var scrollView:UIScrollView?
    var currentTextField:UITextField?
    var dataScroll:UIEdgeInsets?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EGBaseViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        for view in self.view.subviews {
            if let noticeSubView = view as? UIScrollView {
                scrollView = noticeSubView
                dataScroll = scrollView?.contentInset
            }
        }
        
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EGBaseViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EGBaseViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView!.contentInset = contentInsets
        self.scrollView!.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = currentTextField {
            if (!CGRectContainsPoint(aRect, activeFieldPresent.frame.origin)) {
                self.scrollView!.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        currentTextField = nil
        
        //let info : NSDictionary = notification.userInfo!
        //let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        //let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        
        self.scrollView!.contentInset = dataScroll!
        self.scrollView!.scrollIndicatorInsets = dataScroll!

    }
    
    //MARK: UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        currentTextField = nil
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
