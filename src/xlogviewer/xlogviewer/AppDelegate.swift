//
//  AppDelegate.swift
//  xlogviewer
//
//  Created by stoprain on 24/01/2018.
//  Copyright © 2018 com.yunio. All rights reserved.
//

import Cocoa
import SnapKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let v = FileListView(frame: NSRect.zero)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //[[NSApplication sharedApplication] mainWindow]
        
        if let superview = NSApplication.shared.mainWindow?.contentView {
            superview.addSubview(self.v)
            self.v.snp.makeConstraints { (make) in
                make.edges.equalTo(superview)
            }
        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

