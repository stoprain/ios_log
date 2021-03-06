//
//  DragView.swift
//  ios_log
//
//  Created by stoprain on 20/02/2017.
//  Copyright © 2017 stoprain. All rights reserved.
//

import Cocoa
import YNLib

class DragView: NSScrollView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        self.register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo?) {
        if let paths = sender?.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as? [String] {
            if let path = paths.first {
                let components = path.characters.split(separator: "/")
                _ = components.dropLast(1).map(String.init).joined(separator: "/")
                let words = components.count-1
                let tail = components.dropFirst(words).map(String.init)[0]
                if tail.pathExtension == "log" || tail.pathExtension == "xlog" {
                    let dpath = documentPath.stringByAppendingPathComponent(path: tail)
                    let f = FileManager.default
                    do {
                        if f.fileExists(atPath: dpath) {
                            try f.removeItem(atPath: dpath)
                        }
                        
                        try f.copyItem(atPath: path, toPath: dpath)
                        self.runPythonScript(path: dpath)
                    } catch {
                        
                    }
                }
            }
        }

        
        //python decode_mars_log_file.py path
        
        //display the file
    }
    
    private func runPythonScript(path: String) {
        if path.pathExtension == "xlog" {
            let process = Process()
            process.launchPath = "/usr/bin/python"
            let scriptPath = Bundle.main.path(forResource: "decode_mars_nocrypt_log_file", ofType: "py")
            process.arguments = [scriptPath!, path]
            
            process.standardInput = Pipe()
            process.standardOutput = Pipe()
            process.standardError = Pipe()

            process.launch()
            process.waitUntilExit()
            let exitCode = process.terminationStatus
            if exitCode != 0 {
                Swift.print("process Error!")
            }
            
//            self.cat(path: path)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    private func cat(path: String) {
        
        let process = Process()
        process.launchPath = "/bin/cat"
//        let scriptPath = Bundle.main.path(forResource: "decode_mars_nocrypt_log_file", ofType: "py")
        process.arguments = [path]
        
        let p = Pipe()
        process.standardInput = Pipe()
        process.standardOutput = p
        process.standardError = Pipe()
        let h = p.fileHandleForReading
//        h.waitForDataInBackgroundAndNotify()
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: nil, queue: OperationQueue.main, using: { (noti) in
//            let h = noti.object as? FileHandle
//            if let d = h?.availableData {
//                let s = String(data: d, encoding: String.Encoding.utf8)
//                Swift.print("pipe output \(s.debugDescription)")
//            }
//            if let c = h?.readDataToEndOfFile() {
//                let s = String(data: c, encoding: String.Encoding.utf8)
//                Swift.print("pipe output \(s.debugDescription)")
//            }
//        })
        
        process.launch()
        let s = String(data: h.readDataToEndOfFile(), encoding: String.Encoding.utf8)
        Swift.print("pipe output \(s.debugDescription)")
        process.waitUntilExit()
        let exitCode = process.terminationStatus
        if exitCode != 0 {
            Swift.print("process Error!")
        }
    }
    
}
