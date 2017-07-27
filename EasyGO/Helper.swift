//
//  Helper.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/30/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation
import Firebase
import SystemConfiguration

let APP_ID = "DF132F4C-4CA3-4612-FF53-E07996566000"
let SECRET_KEY = "C09CE4E9-77B4-0484-FF14-71DD0B0C6D00"
let VERSION_NUM = "v1"

//MARK: Format Date
private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}

//MARK: UserDefaults
func isFirstRun() -> Bool {
    
    var firstLoad: Bool = false
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    if userDefaults.boolForKey("firstRun") {
        firstLoad = userDefaults.boolForKey("firstRun")
    }
    
    return firstLoad
}

func loadUserFirstRun() {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(true, forKey: "firstRun")
    userDefaults.synchronize()
}

//MARK: Show Alert
func showAlert(target: UIViewController, description: NSString) {
    
    let ac = UIAlertController(title: "Attention", message: description as String, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    target.presentViewController(ac, animated: true, completion: nil)
    
}

//MARK: Check Connection
func connectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
        return false
    }
    
    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.Reachable)
    let needsConnection = flags.contains(.ConnectionRequired)
    
    return (isReachable && !needsConnection)
}

//MARK: Validated Email
func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}


