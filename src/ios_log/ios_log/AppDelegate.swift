//
//  AppDelegate.swift
//  ios_log
//
//  Created by stoprain on 17/02/2017.
//  Copyright © 2017 stoprain. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    static var t: NSTextView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let f = NSRect(x: 0, y: 0, width: self.window.frame.size.width, height: self.window.frame.size.height)
        let scroll = NSScrollView(frame: f)
        
        AppDelegate.t = NSTextView(frame: f)
        scroll.addSubview(AppDelegate.t)
        scroll.documentView = AppDelegate.t
        scroll.hasVerticalScroller = true
        self.window.contentView?.addSubview(scroll)
        
        
//        self.window.contentView?.addSubview(AppDelegate.t!)
//        
        start { (a) in
            let b = String(cString: a!)
            let a = NSAttributedString(string: b)
            AppDelegate.t?.textStorage?.append(a)
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

