//
//  EGSettingsViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/14/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import UIKit
import Firebase

class EGSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var btnUploadPhoto: UIButton!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelUserEmail: UILabel!
    @IBOutlet weak var imgUserPhoto: UIImageView!
    
    @IBOutlet weak var passcodeSwitch: UISwitch!
    @IBOutlet weak var changePasscodeButton: UIButton!
    
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
        
        self.imgUserPhoto.hidden = true
        self.imgUserPhoto.layer.cornerRadius = self.imgUserPhoto.frame.size.height/2
        self.imgUserPhoto.layer.masksToBounds = true
        self.imgUserPhoto.layer.borderWidth = 0
        
        if let user = DataService.dataService.currentUser {
            
            self.labelUserName.text = user.displayName
            self.labelUserEmail.text = user.email
            
            if user.photoURL != nil {
                if let data = NSData(contentsOfURL: user.photoURL!) {
                    self.imgUserPhoto.hidden = false
                    self.imgUserPhoto.image = UIImage.init(data: data)
                }
            } else {
                //no user is signed in
            }

        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
    }
    
    func updatePasscodeView() {
        
        let hasPasscode = configuration.repository.hasPasscode
        
        changePasscodeButton.hidden = !hasPasscode
        passcodeSwitch.on = hasPasscode
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    @IBAction func logoutProfile(sender: AnyObject) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logout = UIAlertAction(title: "Log Out", style: .Destructive) { (alert: UIAlertAction!) in
           DataService.dataService.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) in
        }
        
        optionMenu.addAction(logout)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func uploadPhoto(sender: AnyObject) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) in
            camera.presentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) in
            camera.presentPhotoLibrary(self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) in
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    @IBAction func passcodeSwitchValueChange(sender: UISwitch) {
        
        let passcodeVC: PasscodeLockViewController
        
        if passcodeSwitch.on {
            
            passcodeVC = PasscodeLockViewController(state: .SetPasscode, configuration: configuration)
            
        } else {
            
            passcodeVC = PasscodeLockViewController(state: .RemovePasscode, configuration: configuration)
            
            passcodeVC.successCallback = { lock in
                
                lock.repository.deletePasscode()
            }
        }
        
        presentViewController(passcodeVC, animated: true, completion: nil)
    }
    
    @IBAction func changePasscodeButtonTap(sender: UIButton) {
        
        let repo = UserDefaultsPasscodeRepository()
        let config = PasscodeLockConfiguration(repository: repo)
        
        let passcodeLock = PasscodeLockViewController(state: .ChangePasscode, configuration: config)
        
        presentViewController(passcodeLock, animated: true, completion: nil)
    }
    
    //MARK: ImagePickerController Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.imgUserPhoto.image = image
        
        var data = NSData()
        data = UIImageJPEGRepresentation(image, 1.0)!
        
        ProgressHUD.show("Please wait...", interaction: false)
        DataService.dataService.setPhotoUser(data)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }


}
