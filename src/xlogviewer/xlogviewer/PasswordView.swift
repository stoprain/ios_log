//
//  PasswordView.swift
//  xlogviewer
//
//  Created by stoprain on 25/01/2018.
//  Copyright © 2018 com.yunio. All rights reserved.
//

import Cocoa
import SwiftHEXColors

protocol PasswordViewDelegate: NSObjectProtocol {
    func didEnterPassword(s: String)
}

class PasswordView: NSView {
    
    weak var delegate: PasswordViewDelegate?
    let password = NSTextField(frame: NSRect.zero)
    private let button = NSButton(frame: NSRect.zero)
    private let cancel = NSButton(frame: NSRect.zero)
    private let today = NSButton(frame: NSRect.zero)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
        
        self.password.font = NSFont.systemFont(ofSize: 16)
        self.password.placeholderString = "Password"
        self.password.nextKeyView = self.button
        self.addSubview(self.password)
        
        self.button.title = "OK"
        self.button.action = #selector(PasswordView.okTapped)
        self.button.nextKeyView = self.cancel
        self.addSubview(self.button)
        
        self.cancel.title = "Cancel"
        self.cancel.action = #selector(PasswordView.cancelTapped)
        self.cancel.nextKeyView = self.today
        self.addSubview(self.cancel)
        
        self.today.title = "Today"
        self.today.action = #selector(PasswordView.todayTapped)
        self.today.nextKeyView = self.password
        self.addSubview(self.today)
        
        self.password.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(10)
            make.height.equalTo(44)
            make.top.equalTo(self).offset(10)
        }
        
        self.button.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(10)
            make.top.equalTo(self.password.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
        
        self.cancel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(10)
            make.top.equalTo(self.button.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
        
        self.today.snp.makeConstraints { (make) in
            make.left.right.equalTo(self).inset(10)
            make.top.equalTo(self.cancel.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func okTapped() {
        self.delegate?.didEnterPassword(s: self.password.stringValue)
        self.password.stringValue = ""
    }
    
    @objc private func cancelTapped() {
        self.isHidden = true
    }
    
    @objc private func todayTapped() {
        let f = DateFormatter()
        f.dateFormat = "YYYYMMDD"
        let s = f.string(from: Date())
        self.delegate?.didEnterPassword(s: s)
    }
    
}
