//
//  Contact.swift
//  loopr-ios
//
//  Created by kenshin on 2018/12/12.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class Contact: CustomStringConvertible {
    var name: String
    var address: String
    var note: String
    var tag: String
    var description: String
    
    init(name: String, address: String, note: String = "") {
        self.name = name
        self.address = address
        self.note = note
        self.tag = ""
        self.description = "\(name) \(address)"
        self.tag = initialChar(name)
    }
    
    func initialChar(_ Chinese: String) -> String {
        let temp:CFMutableString = CFStringCreateMutableCopy(nil, 0, Chinese as CFString);
        CFStringTransform(temp, nil, kCFStringTransformToLatin, false)
        CFStringTransform(temp, nil, kCFStringTransformStripCombiningMarks, false)
        guard let cfString = CFStringCreateWithSubstring(nil, temp, CFRangeMake(0, 1)) else { return "#"}
        var result = (cfString as String).uppercased()
        let regex = try! NSRegularExpression(pattern: "[A-Z]{1}")
        if regex.matches(in: result, range: NSRange(location: 0, length: 1)).count == 0 {
            result = "#"
        }
        return result
    }
}
