//
//  EGRegisterUserViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/14/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation

class UserDefaultsPasscodeRepository: PasscodeRepositoryType {
    
    private let passcodeKey = "passcode.lock.passcode"
    
    private lazy var defaults: NSUserDefaults = {
        
        return NSUserDefaults.standardUserDefaults()
    }()
    
    var hasPasscode: Bool {
        
        if passcode != nil {
            return true
        }
        
        return false
    }
    
    var passcode: [String]? {
        
        return defaults.valueForKey(passcodeKey) as? [String] ?? nil
    }
    
    func savePasscode(passcode: [String]) {
        
        defaults.setObject(passcode, forKey: passcodeKey)
        defaults.synchronize()
    }
    
    func deletePasscode() {
        
        defaults.removeObjectForKey(passcodeKey)
        defaults.synchronize()
    }
}
