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

    var item : NSStatusItem? = nil
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Insert code here to initialize your application
        
        NSUserNotificationCenter.default.delegate = self // allow for notifications to show even if your app is visible
        
        //setup status bar and menu
        item = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        item?.title = "B.A.M"
        
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(title: "Check", action: #selector(AppDelegate.check), keyEquivalent: "")
        )
        menu.addItem(
            NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.preferences), keyEquivalent: "")
        )

        menu.addItem( NSMenuItem.separator())
        menu.addItem(
            NSMenuItem(title: "Quit", action: #selector(AppDelegate.quit), keyEquivalent: "")
        )
        item?.menu = menu
        
        
        // configure test timer
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(AppDelegate.checkStatus), userInfo: nil, repeats: true)
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /// required for notification to show
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func checkStatus() {
        showPowerNotification(info: checkPower(), forced: false)
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
    
    func quit() {
        NSApplication.shared().terminate(self)
    }
    
    func preferences() {
        let storyboard = NSStoryboard(name: "Main", bundle:nil)
        let prefController = storyboard.instantiateController(withIdentifier: "Preferences") as! NSWindowController
        let prefWindow = prefController.window
        let application = NSApplication.shared()
        application.runModal(for: prefWindow!)
        prefWindow?.close()
        application.stopModal()
    }
    
    func check() {
        showPowerNotification(info: checkPower(), forced: true)
    }
    
    func showPowerNotification( info: PowerInfo, forced: Bool) {
        
        if ( info.capacity <= 25 && !info.charging ) {
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
    
    func checkPower() -> PowerInfo {
    
        let blob = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(blob).takeRetainedValue() as Array
        for ps in sources {
            let info: [String: Any] = IOPSGetPowerSourceDescription(blob, ps).takeUnretainedValue() as! Dictionary
            print(info)
            
            return PowerInfo(
                capacity: info[kIOPSCurrentCapacityKey] as! Int,
                charging: info[kIOPSIsChargingKey] as! Bool
            )
        }
        
        return PowerInfo(capacity: 100, charging: true);
        
    }

    
    class PowerInfo {
        var capacity: Int
        var charging: Bool
        
        init( capacity: Int, charging: Bool ) {
            self.capacity = capacity
            self.charging = charging
        }
    }

}

