//
//  Contact.swift
//  loopr-ios
//
//  Created by kenshin on 2018/12/12.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation

class Contact: NSObject, NSCoding {
    var name: String
    var address: String
    var note: String
    var tag: String
    
    init(name: String, address: String, note: String) {
        self.name = name
        self.address = address
        self.note = note
        self.tag = ""
        super.init()
        self.tag = initialChar(name)
    }
    
    // MARK: - NSCoding
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        address = aDecoder.decodeObject(forKey: "address") as! String
        note = aDecoder.decodeObject(forKey: "note") as! String
        tag = aDecoder.decodeObject(forKey: "tag") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(tag, forKey: "tag")
    }
    
    func initialChar(_ Chinese: String) -> String {
        let temp = CFStringCreateMutableCopy(nil, 0, Chinese as CFString)
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
