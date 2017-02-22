//
//  AppDelegate.swift
//  ios_log
//
//  Created by stoprain on 17/02/2017.
//  Copyright © 2017 stoprain. All rights reserved.
//

import Cocoa
import SnapKit
import YNLib

class Device: NSObject {
    var name: String = ""
    var nodes: [Node] = [Node]()
}

class Node: NSObject {
    var name: String = ""
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,
    NSOutlineViewDataSource, NSOutlineViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var sourceListView: NSOutlineView?
    @IBOutlet weak var textView: NSTextView?
    
    var ios = Device()
    var mac = Device()

//    static var t: NSTextView!
    
    func checkDocumentPath() {
        let dpath = AppSandboxHelper.documentsPath + "/ios_log"
        let f = FileManager.default
        if !f.fileExists(atPath: dpath) {
            do {
                try f.createDirectory(atPath: dpath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
    }
    
    func reloadLogs() {
        self.mac.nodes.removeAll()
        let dpath = AppSandboxHelper.documentsPath + "/ios_log"
        let f = FileManager.default
        let e = f.enumerator(atPath: dpath)
        while let element = e?.nextObject() as? String {
            if element.hasSuffix(".log") {
                let n = Node()
                n.name = element
                self.mac.nodes.append(n)
            }
        }
        
        self.sourceListView?.reloadData()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.checkDocumentPath()
        
        self.ios.name = "ios"
        self.mac.name = "mac"
        
        let current = Node()
        current.name = "current"
        self.ios.nodes.append(current)
        
        self.sourceListView?.dataSource = self
        self.sourceListView?.delegate = self
        
        textView?.isEditable = false
        
        self.reloadLogs()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reload"), object: nil, queue: OperationQueue.main) { (n) in
            self.reloadLogs()
        }
        
        // Insert code here to initialize your application
//        let scroll = NSScrollView(frame: NSRect.zero)
//        
//        let f = NSRect(x: 0, y: 0, width: self.window.contentView!.frame.size.width, height: self.window.contentView!.frame.size.height)
//        AppDelegate.t = NSTextView(frame: f)
//        scroll.addSubview(AppDelegate.t)
//        scroll.documentView = AppDelegate.t
//        scroll.hasVerticalScroller = true
//        scroll.hasHorizontalScroller = true
//        self.window.contentView?.addSubview(scroll)
//        
//        AppDelegate.t.snp.makeConstraints { (make) in
//            make.width.equalTo(self.window.contentView!)
//            make.top.equalTo(0)
//            make.left.equalTo(0)
//        }
//        
//        scroll.snp.makeConstraints { (make) in
//            make.size.equalTo(self.window.contentView!)
//            make.top.equalTo(0)
//            make.left.equalTo(0)
//        }
//        
//        
////        self.window.contentView?.addSubview(AppDelegate.t!)
////        
//        start { (a) in
//            let b = String(cString: a!)
//            let a = NSAttributedString(string: b)
//            AppDelegate.t?.textStorage?.append(a)
//            AppDelegate.t.sizeToFit()
//        }
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // NSOutlineViewDataSource
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item: Any = item {
            switch item {
            case let device as Device:
                return device.nodes[index]
            default:
                return self
            }
        } else {
            switch index {
                case 0:
                return self.ios
                default:
                return self.mac
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        switch item {
        case let deivce as Device:
            return (deivce.nodes.count > 0) ? true : false
        default:
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item: Any = item {
            switch item {
            case let device as Device:
                return device.nodes.count
            default:
                return 0
            }
        } else {
            return 2
        }
    }

    // NSOutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        switch item {
        case let device as Device:
            let view = outlineView.make(withIdentifier: "HeaderCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = device.name
            }
            return view
        case let node as Node:
            let view = outlineView.make(withIdentifier: "DataCell", owner: self) as! NSTableCellView
            if let textField = view.textField {
                textField.stringValue = node.name
            }
            return view
        default:
            return nil
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        print(notification)
        if let n = self.sourceListView?.item(atRow: self.sourceListView!.selectedRow) as? Node {
            let dpath = AppSandboxHelper.documentsPath + "/ios_log" + "/" + n.name
            do {
                let t = try String(contentsOfFile: dpath)
                self.textView?.string = t
            } catch {
                
            }
        }
    }

}

