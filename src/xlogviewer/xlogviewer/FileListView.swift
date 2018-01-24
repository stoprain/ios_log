//
//  FileListView.swift
//  xlogviewer
//
//  Created by stoprain on 24/01/2018.
//  Copyright © 2018 com.yunio. All rights reserved.
//

import Cocoa

class FileListView: NSScrollView, NSTableViewDataSource, NSTableViewDelegate {
    
    private let tableView = NSTableView(frame: NSRect.zero)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        //self.hasVerticalScroller = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.documentView = self.tableView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 0
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var result = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self)
        
        return result
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 44
    }
    
}
