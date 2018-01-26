//
//  FileListView.swift
//  xlogviewer
//
//  Created by stoprain on 24/01/2018.
//  Copyright © 2018 com.yunio. All rights reserved.
//

import Cocoa
import ZipArchive
import CommonCrypto

class FileListView: NSScrollView, NSTableViewDataSource, NSTableViewDelegate,
    PasswordViewDelegate {
    
    let passwordView = PasswordView(frame: NSRect.zero)
    private let tableView = NSTableView(frame: NSRect.zero)
    private var lastPath = ""
    private var filenames = [String]()
    private var filedatas = [String: Data]()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        //self.hasVerticalScroller = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.documentView = self.tableView
        
        self.tableView.doubleAction = #selector(FileListView.doubleClickOnResultRow)
        
        let c = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Column"))
        c.title = "zip, xlog"
        self.tableView.addTableColumn(c)
        
        self.hasVerticalScroller = true
        
        self.registerForDraggedTypes([kUTTypeFileURL as NSPasteboard.PasteboardType])
    }
    
    @objc private func doubleClickOnResultRow() {
        if !self.passwordView.isHidden {
            return
        }
        let name = self.filenames[self.tableView.clickedRow]
        let ds = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.downloadsDirectory, .userDomainMask, true)[0]
        let data = self.filedatas[name]!
        if name.contains(".xlog") {
            let s = LogDecoder.run(data: data)
            
            let url = URL(fileURLWithPath: "\(ds)/\(name).log")
            do {
                try s.data(using: .utf8)?.write(to: url)
            } catch (let e) {
                print(e)
            }
            
        } else {

            let url = URL(fileURLWithPath: "\(ds)/\(name)")
            do {
                try data.write(to: url)
            } catch (let e) {
                print(e)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK drag
    
    //1.
//    let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        return true
//        var canAccept = false
//
//        //2.
//        let pasteBoard = draggingInfo.draggingPasteboard()
//
//        //3.
//        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
//            canAccept = true
//        }
//        return canAccept
        
    }
    
    //1.
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    //2.
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = 2
            path.stroke()
        }
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        //1.
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        //2.
        let _ = convert(draggingInfo.draggingLocation(), from: nil)
        //3.
//        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
//            print(urls)
//            return true
//        }
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:nil) as? [URL], urls.count > 0 {
            self.handleUrls(urls: urls)
            return true
        }
        return false
        
    }
    
    private func handleUrls(urls: [URL]) {
        for u in urls {
            if u.path.contains(".zip") {
                self.lastPath = u.path
                self.passwordView.isHidden = false
                self.passwordView.password.becomeFirstResponder()
                break
            } else if u.path.contains(".xlog") {
                let name = (u.path as NSString).lastPathComponent
                self.filenames.removeAll()
                self.filedatas.removeAll()
                self.filenames.append(name)
                self.filedatas[name] = try! Data(contentsOf: u)
                self.tableView.reloadData()
                break
            }
        }
    }
    
    // MARK: NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.filenames.count
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as? NSTextField
        if result == nil {
            result = NSTextField(frame: NSRect.zero)
            result?.identifier = NSUserInterfaceItemIdentifier(rawValue: "cell")
            result?.isEditable = false
        }
        result?.stringValue = self.filenames[row]
        return result
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 44
    }
    
    // MARK: PasswordViewDelegate
    
    func didEnterPassword(s: String) {
        if s.count == 0 {
            let zip = ZipArchive()
            let r = zip.unzipOpenFile(self.lastPath)
            if r {
                self.filedatas = zip.unzipFileToMemory() as! [String: Data]
                self.filenames.removeAll()
                for k in self.filedatas {
                    self.filenames.append(k.key)
                }
                self.tableView.reloadData()
            }
            self.passwordView.isHidden = true
            zip.unzipCloseFile()
        } else {
            let zip = ZipArchive()
            let r = zip.unzipOpenFile(self.lastPath, password: s)
            if r {
                self.filedatas = zip.unzipFileToMemory() as! [String: Data]
                self.filenames.removeAll()
                for k in self.filedatas {
                    self.filenames.append(k.key)
                }
                self.tableView.reloadData()
            }
            self.passwordView.isHidden = true
            zip.unzipCloseFile()
        }
    }
    
}
