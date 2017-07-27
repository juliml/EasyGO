//
//  EGFirebaseable.swift
//  EasyGO
//
//  Created by Juliana Lima on 6/14/16.
//  Copyright © 2016 FixmyIphones. All rights reserved.
//

import Foundation
import FirebaseDatabase

class EGFirebaseable {

    lazy var serverRef = FIRDatabase.database().reference()
    
    func toDictionary() -> [String:String]{
        var dir = [String:String]()
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            guard let key = child.label else { continue }
            let value: String = child.value as! String
            dir[key] = value
        }
        
        return dir
    }
    
}
