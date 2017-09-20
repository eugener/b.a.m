//
//  AppDelegate.swift
//  B.A.M
//
//  Created by Eugene Ryzhikov on 9/17/17.
//  Copyright © 2017 Eugene Ryzhikov. All rights reserved.
//

import Cocoa
import Foundation
import IOKit.ps
//import IOKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate  {

    lazy var item : NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    lazy var storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle:nil)
    lazy var prefController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Preferences")) as! NSWindowController
    lazy var viewController = prefController.contentViewController as! ViewController
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Insert code here to initialize your application
        
        let capacity: Int = UserDefaults.standard.integer(forKey: "maxBatteryCapacity")
        //print("Loaded: \(capacity)")
        viewController.maxBatteryCapacity = (capacity == 0) ? 25: capacity

        // allow for notifications to show even if your app is visible/top
        NSUserNotificationCenter.default.delegate = self
        
        //setup status bar and menu
        item.title = "B.A.M"
        
        let menu = NSMenu()
        menu.addItem(
           withTitle: "Check",
           action: #selector(AppDelegate.check),
           keyEquivalent: ""
        )
        menu.addItem(
           withTitle: "Preferences...",
           action: #selector(AppDelegate.preferences),
           keyEquivalent: ""
        )

        menu.addItem( NSMenuItem.separator() )

        menu.addItem(
           withTitle: "Quit",
           action: #selector(AppDelegate.quit),
           keyEquivalent: ""
        )
        item.menu = menu
        
        
        // configure test timer
        Timer.scheduledTimer(
                timeInterval: 60.0,
                target: self,
                selector: #selector(AppDelegate.checkStatus),
                userInfo: nil,
                repeats: true)
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /// required for notification to show
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    @objc func checkStatus() {
        showPowerNotification(info: getPowerStatus(), forced: false)
    }
    
    private func scheduleLocalNotification( title: String, subtitle: String, infoText: String) {
        let notification = NSUserNotification()
        
        // All these values are optional
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = infoText
        //notification.contentImage = contentImage
        notification.soundName = NSUserNotificationDefaultSoundName
        
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func preferences() {
        let prefWindow = prefController.window
        let application = NSApplication.shared
        application.runModal(for: prefWindow!)
        prefWindow?.close()
        application.stopModal()
    }
    
    @objc func check() {
        showPowerNotification(info: getPowerStatus(), forced: true)
    }

    //private let minPowerCapacity = 25
    
    func showPowerNotification(info: PowerStatus, forced: Bool) {
        
        print( "Checking for max capacity of \(viewController.maxBatteryCapacity)")
        
        if ( info.capacity <= viewController.maxBatteryCapacity && !info.charging ) {
            scheduleLocalNotification(
                title: "B.A.M",
                subtitle: "Your power is critical: \(info.capacity)%",
                infoText: "Please connect your cord or risk losing everything."
            )
        } else {
            if ( forced ) {
                scheduleLocalNotification(
                    title: "B.A.M",
                    subtitle: "All is good: \(info.capacity)%",
                    infoText: "Thank you for checking!"
                )
            }
        }
    }
    
    func getPowerStatus() -> PowerStatus {
    
        let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as Array

        for ps in sources {
            let info: [String: Any] = IOPSGetPowerSourceDescription(blob, ps).takeUnretainedValue() as! Dictionary
            print(info)
            
            return PowerStatus(
                capacity: info[kIOPSCurrentCapacityKey] as! Int,
                charging: info[kIOPSIsChargingKey] as! Bool
            )
        }
        
        return PowerStatus(capacity: 100, charging: true);
        
    }

    


}

class PowerStatus {

    var capacity: Int
    var charging: Bool

    init( capacity: Int, charging: Bool ) {
        self.capacity = capacity
        self.charging = charging
    }
}

