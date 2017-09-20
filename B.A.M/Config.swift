//
//  Config.swift
//  B.A.M
//
//  Created by Eugene Ryzhikov on 9/20/17.
//  Copyright © 2017 Eugene Ryzhikov. All rights reserved.
//

import Foundation

struct Config {
    
    private static let sMaxBatteryCapacity = "maxBatteryCapacity"
    
    private init() { }
    
    static var maxBatteryCapacity: Int {
        get {
            return UserDefaults.standard.integer(forKey: sMaxBatteryCapacity)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: sMaxBatteryCapacity)
        }
    }
}
