//
//  ViewController.swift
//  B.A.M
//
//  Created by Eugene Ryzhikov on 9/17/17.
//  Copyright © 2017 Eugene Ryzhikov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var slMaxBatteryCapacity: NSSlider!
    @IBOutlet weak var lbMaxBatteryCapacity: NSTextField!
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let value = slMaxBatteryCapacity.integerValue
        lbMaxBatteryCapacity.stringValue = String(value)
        Config.maxBatteryCapacity = value // store updated capacity
    }
    
    var maxBatteryCapacity: Int {
        get {
            return slMaxBatteryCapacity.integerValue
        }
        set {
            slMaxBatteryCapacity.integerValue = newValue
            sliderValueChanged(self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func viewDidDisappear() {
        NSApplication.shared.stopModal()
    }


}

