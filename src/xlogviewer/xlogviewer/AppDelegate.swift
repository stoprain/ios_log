//
//  AppDelegate.swift
//  xlogviewer
//
//  Created by stoprain on 25/01/2018.
//  Copyright © 2018 com.yunio. All rights reserved.
//

import Cocoa
import SnapKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let v = FileListView(frame: NSRect.zero)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DispatchQueue.main.async {
            if let superview = NSApplication.shared.mainWindow?.contentView {
                superview.addSubview(self.v)
                self.v.snp.makeConstraints { (make) in
                    make.edges.equalTo(superview)
                }
                
                self.v.passwordView.isHidden = true
                self.v.passwordView.delegate = self.v
                superview.addSubview(self.v.passwordView)
                self.v.passwordView.snp.makeConstraints { (make) in
                    make.edges.equalTo(superview)
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let w = sender.windows.first {
            if w.isVisible {
                w.orderFront(self)
            } else {
                w.makeKeyAndOrderFront(self)
            }
        }
        return true
    }


}

