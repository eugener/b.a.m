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
    private static let defaultMaxBatteryCapacity: Int = 25
    
    private static let userDefaults = UserDefaults.standard
    
    private init() { }
    
    static var maxBatteryCapacity: Int {
        get {
            let capacity = userDefaults.integer(forKey: sMaxBatteryCapacity)
            return (capacity == 0) ? defaultMaxBatteryCapacity: capacity
        }
        set {
            userDefaults.set(newValue, forKey: sMaxBatteryCapacity)
        }
    }
}
