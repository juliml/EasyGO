//
//  EGRegisterUserViewController.swift
//  EasyGO
//
//  Created by Juliana Lima on 7/14/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation

struct PasscodeLockConfiguration: PasscodeLockConfigurationType {
    
    let repository: PasscodeRepositoryType
    let passcodeLength = 4
    var isTouchIDAllowed = true
    let shouldRequestTouchIDImmediately = true
    let maximumInccorectPasscodeAttempts = -1
    
    init(repository: PasscodeRepositoryType) {
        
        self.repository = repository
    }
    
    init() {
        
        self.repository = UserDefaultsPasscodeRepository()
    }
}
