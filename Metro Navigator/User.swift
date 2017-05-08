//
//  User.swift
//  Metro Navigator
//
//  Created by Illia Lysenko on 5/8/17.
//  Copyright © 2017 intellogic. All rights reserved.
//

import Foundation

class User {
    
    static var city: String {
        get {
            return UserDefaults.standard.object(forKey: "currentCity") as! String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentCity")
        }
    }
    
    static var cityIsSet: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "cityIsSet")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "cityIsSet")
        }
    }
}
