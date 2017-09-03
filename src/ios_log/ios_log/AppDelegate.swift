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

let documentPath = AppSandboxHelper.documentsPath + "/ios_log"

extension String {
    var ns: NSString {
        return self as NSString
    }
    func stringByAppendingPathComponent(path: String) -> String {
        return ns.appendingPathComponent(path)
    }
    var pathExtension: String? {
        return ns.pathExtension
    }
    var lastPathComponent: String? {
        return ns.lastPathComponent
    }
}

class Device: NSObject {
    var name: String = ""
    var nodes: [Node] = [Node]()
}

class Node: NSObject {
    var name: String = ""
    var socketAddress: Int32 = 0
    var messages: [String] = [String]()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,
    NSOutlineViewDataSource, NSOutlineViewDelegate,
    NSTextFieldDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var sourceListView: NSOutlineView?
    @IBOutlet weak var textView: NSTextView?
    @IBOutlet weak var textField: NSTextField?
    
    static var ios = Device()
    static var mac = Device()
    var logs = [String]()
    var origin = ""
    var selectedNode: Node?

//    static var t: NSTextView!
    
    func doFilter() {
        self.textView?.string = ""
        let s = self.textField?.stringValue.lowercased() ?? ""
        if s.characters.count == 0 {
            self.textView?.string = self.origin
            return
        }
        self.textView?.textStorage?.beginEditing()
        for l in self.logs {
            if let r = l.lowercased().range(of: s) {
                let a = NSMutableAttributedString(string: l + "\n")
                let start = l.distance(from: l.startIndex, to: r.lowerBound)
                let end = l.distance(from: l.startIndex, to: r.upperBound) - start
                a.addAttributes([NSForegroundColorAttributeName: NSColor.orange], range: NSMakeRange(start, end))
                self.textView?.textStorage?.append(a)
            }
        }
        self.textView?.textStorage?.endEditing()
    }
    
    func filterLogs(s: String) {
        Chrono.start(0)
        self.origin = s
        self.logs = s.components(separatedBy: "\n")
        Chrono.stop(0) { (time) in
            print("components separatedBy spent \(time)")
        }
        Chrono.start(0)
        self.textView?.textStorage?.beginEditing()
        self.textView?.string = ""
        for l in self.logs {
            let a = NSAttributedString(string: l + "\n")
            self.textView?.textStorage?.append(a)
        }
        self.textView?.textStorage?.endEditing()
        Chrono.stop(0) { (time) in
            print("textStorage spent \(time)")
        }
    }
    
    func checkDocumentPath() {
        let dpath = documentPath
        let f = FileManager.default
        if !f.fileExists(atPath: dpath) {
            do {
                try f.createDirectory(atPath: dpath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
    }
    
    func reloadLogs() {
        AppDelegate.mac.nodes.removeAll()
        let dpath = documentPath
        let f = FileManager.default
        let e = f.enumerator(atPath: dpath)
        while let element = e?.nextObject() as? String {
            if element.hasSuffix(".log") {
                let n = Node()
                n.name = element
                AppDelegate.mac.nodes.append(n)
            }
        }
        
        self.sourceListView?.reloadData()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.checkDocumentPath()
        
        AppDelegate.ios.name = "ios"
        AppDelegate.mac.name = "mac"
        
        self.sourceListView?.dataSource = self
        self.sourceListView?.delegate = self
        
        textView?.isEditable = false
        self.textField?.delegate = self
        self.textView?.lnv_setUpLineNumberView()
        
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
        
        start({ (address, cchar) in
            let b = String(cString: cchar!)
            //print("onmessage for socket \(address)")
//            if t == 0 {
//                print("disconnect deivce \(b)")
//            } else if t == 1 {
//                print("connect device \(b)")
//            } else if t == 2 {
//                
//            }
            
            for a in AppDelegate.ios.nodes {
                if a.socketAddress == address {
                    a.messages.append(b)

                    
                    if let d = NSApplication.shared().delegate as? AppDelegate {
                        if d.selectedNode == a {
                            d.logs.append(b)
                            let s = d.textField?.stringValue.lowercased() ?? ""
                            if s.characters.count > 0 {
                                //filter
                                if let r = b.lowercased().range(of: s) {
                                    let aa = NSMutableAttributedString(string: b + "\n")
                                    let start = b.distance(from: b.startIndex, to: r.lowerBound)
                                    let end = b.distance(from: b.startIndex, to: r.upperBound) - start
                                    aa.addAttributes([NSForegroundColorAttributeName: NSColor.orange], range: NSMakeRange(start, end))
                                    
                                    let scroll = (NSMaxY(d.textView!.visibleRect) == NSMaxY(d.textView!.bounds))
                                    d.textView?.textStorage?.append(aa)
                                    if scroll {
                                        d.textView?.scrollToEndOfDocument(nil)
                                    }

                                }
                                
                                return
                            } else {
                                let aa = NSAttributedString(string: b + "\n")
                                let scroll = (NSMaxY(d.textView!.visibleRect) == NSMaxY(d.textView!.bounds))
                                d.textView?.textStorage?.append(aa)
                                if scroll {
                                    d.textView?.scrollToEndOfDocument(nil)
                                }
                            }
                        }

                    }
                    
                    return
                }
            }
            
        }, { (address, cchar) in
            let b = String(cString: cchar!)
            //print("connect deivce \(address) \(b)")
            
            for a in AppDelegate.ios.nodes {
                if a.name == b {
                    // device was added
                    return
                }
            }
            
            let node = Node()
            node.name = b
            node.socketAddress = address
            AppDelegate.ios.nodes.append(node)
            
            if let d = NSApplication.shared().delegate as? AppDelegate {
                d.sourceListView?.reloadData()
            }
            //create node
//            self.sourceListView?.reloadData()
            
        }) { (cchar) in
            let b = String(cString: cchar!)
            //print("disconnect deivce \(b)")
            
            for a in AppDelegate.ios.nodes {
                if a.name == b {
                    // device was added
                    if let i = AppDelegate.ios.nodes.index(of: a) {
                        AppDelegate.ios.nodes.remove(at: i)
                        if let d = NSApplication.shared().delegate as? AppDelegate {
                            d.sourceListView?.reloadData()
                        }
                    }
                }
            }
        }
        
//        start { (t, a) in
//            let b = String(cString: a!)
//            if t == 0 {
//                print("disconnect deivce \(b)")
//            } else if t == 1 {
//                print("connect device \(b)")
//            } else if t == 2 {
//                print("onmessage")
//            }
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
                return AppDelegate.ios
                default:
                return AppDelegate.mac
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
            self.selectedNode = n
            
            if n.socketAddress > 0 {
                let t = n.messages.joined(separator: "\n")
                self.filterLogs(s: t)
            } else {
                let dpath = documentPath.stringByAppendingPathComponent(path: n.name)
                do {
                    var result = ""
                    if let reader = LineReader(path: dpath) {
                        for line in reader {
                            result += line
                        }
                    }
                    self.filterLogs(s: result)
//                    let url = URL(fileURLWithPath: dpath)
//                    let data = try Data(contentsOf: url)
//                    if let t = String(data: data, encoding: String.Encoding.ascii) {
//                        let tt = String(utf8String: t.cString(using: String.Encoding.nonLossyASCII)!)
////                        Swift.print("\(tt)")
//                        self.filterLogs(s: tt!)
//                    }
////                    let t = try NSString(contentsOfFile: dpath, encoding: String.Encoding.utf8.rawValue)
////                    let t = try String(contentsOf: url, encoding: String.Encoding.ascii)
////                    self.filterLogs(s: t as String)
//                    Swift.print("documentPath data \(data.count)")
                } catch (let e) {
                    Swift.print("documentPath error \(e)")
                }
            }
        }
    }
    
    // NSTextFieldDelegate
    
    override func controlTextDidChange(_ obj: Notification) {
        self.doFilter()
    }

}

class LineReader {
    let path: String
    
    fileprivate let file: UnsafeMutablePointer<FILE>!
    
    init?(path: String) {
        self.path = path
        
        file = fopen(path, "r")
        
        guard file != nil else { return nil }
        
    }
    
    var nextLine: String? {
        var line:UnsafeMutablePointer<CChar>? = nil
        var linecap:Int = 0
        defer { free(line) }
        return getline(&line, &linecap, file) > 0 ? String(cString: line!) : nil
    }
    
    deinit {
        fclose(file)
    }
}

extension LineReader: Sequence {
    func  makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            return self.nextLine
        }
    }
}

