//
//  LogDecoder.swift
//  MarslogDecoder
//
//  Created by Rain Qian on 09/01/2018.
//  Copyright © 2018 Rain Qian. All rights reserved.
//

import Cocoa

let magic_no_compress_start  = UInt8(0x03)
let magic_compress_start1  = UInt8(0x05)

class LogDecoder: NSObject {
    
    static func run(data: Data) -> String {
        
            var file_data = data
            var log_string = ""
            while file_data.count > 0 {
                let header_info = file_data.subdata(in: 0..<13)
                let log_start = header_info[0];
                var log_length = 0
                for i in 5...8 {
                    log_length += Int(header_info[i]) * Int(pow(16.0, (Float(i) - 5.0) * 2.0))
                }
                if log_start == magic_no_compress_start {
                    let log_data = file_data.subdata(in: 13..<(13 + log_length))
                    let string = String(data: log_data, encoding: .utf8)
                    log_string = log_string.appending(string ?? "")
                    file_data = file_data.subdata(in: (13 + log_length + 1)..<file_data.count)
                } else if log_start == magic_compress_start1 {
                    var tmp_data: Data = file_data.subdata(in: 13..<(13 + log_length))
                    var d = Data()
                    while tmp_data.count > 0 {
                        var single_log_len = 0
                        for i in 0..<2 {
                            single_log_len += Int(tmp_data[i]) * Int(pow(16.0, (Float(i)) * 2.0))
                        }
                        let dd = tmp_data.subdata(in: 2..<(single_log_len+2))
                        d.append(dd)
                        tmp_data = tmp_data.subdata(in: (single_log_len+2)..<tmp_data.count)
                    }
                    
                    let a = d.decompress(withAlgorithm: Data.CompressionAlgorithm.ZLIB)
                    let string = String(data: a!, encoding: String.Encoding.utf8)
                    log_string = log_string.appending(string ?? "")
                    
                    file_data = file_data.subdata(in: (13 + log_length + 1)..<file_data.count)
                }
            }
            
            return log_string

    }
}
