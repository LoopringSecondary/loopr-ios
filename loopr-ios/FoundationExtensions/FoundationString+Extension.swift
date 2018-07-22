//
//  String+Extension.swift
//  loopr-ios
//
//  Created by xiaoruby on 4/15/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedStringKey.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    //Checks if the given string is an address in hexidecimal encoded form.
    public func isHexAddress() -> Bool {
        if !Set([40, 42]).contains(self.count) {
            return false
        } else if isHex() {
            return true
        }
        return false
    }
    
    public func isHex() -> Bool {
        let lowerCasedSample = self.lowercased()
        if lowerCasedSample.contains("0x") {
            return true
        }
        let unprefixedValue = lowerCasedSample.remove0xPrefix()
        let hexRegex = "^[0-9a-f]+$"
        let regex = try! NSRegularExpression(pattern: hexRegex, options: [])
        let matches = regex.matches(in: unprefixedValue, options: [], range: NSRange(location: 0, length: unprefixedValue.count))
        
        if matches.count > 0 {
            return true
        }
        return false
    }
    
    public func is0xPrefixed() -> Bool {
        return self.hasPrefix("0x") || self.hasPrefix("0X")
    }
    
    public func remove0xPrefix() -> String {
        if is0xPrefixed() {
            let index2 = self.index(self.startIndex, offsetBy: 2)
            return String(self[index2...])
        }
        return self
    }
    
    public func toDecimalPlaces(_ value: Int) -> String {
        let charset: Character = "."
        if let index = self.index(of: charset) {
            let distanceToDecimal = self.distance(from: self.startIndex, to: index).advanced(by: value + 1)
            if let lastIndex = self.index(self.startIndex, offsetBy: distanceToDecimal, limitedBy: self.endIndex) {
                return String(self[..<lastIndex])
            } else {
                return self
            }
        }
        return self
    }
    
    var wholeValue: String {
        if let decimalIndex = self.index(of: ".") {
            return String(self[..<decimalIndex])
        } else {
            return self
        }
    }
    
    public func trimmingFirstConsecutiveCharacters(_ character: String) -> String? {
        let pattern = "^\(character)+(?!$)"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count))
            
            if let match = match {
                let startIndex = String.Index(encodedOffset: match.range.length)
                let endIndex = String.Index(encodedOffset: self.count)
                let result = self[startIndex..<endIndex]
                return String(result)
            } else {
                return self
            }
        } catch {
            print("Failed to create regex pattern for given character")
            return nil
        }
    }
    
    // Reference: https://stackoverflow.com/questions/43360747/how-to-convert-hexadecimal-string-to-an-array-of-uint8-bytes-in-swift
    // compactMap and flatMap https://developer.apple.com/documentation/swift/sequence/2950916-compactmap
    // If use compactMap, get an compiler error Value of type 'StrideTo<String.IndexDistance>' (aka 'StrideTo<Int>') has no member 'compactMap'
    var hexBytes: [UInt8] {
        let hex = Array(self)
        return stride(from: 0, to: count, by: 2).flatMap { UInt8(String(hex[$0..<$0.advanced(by: 2)]), radix: 16) }
    }
    
    var isDouble: Bool {
        if Double(self) != nil {
            return true
        } else {
            return false
        }
    }
    
    var integer: Int? {
        if self.isHex() {
            if self.lowercased().starts(with: "0x") {
                return Int(self.dropFirst(2), radix: 16)
            } else {
                return Int(self, radix: 16)
            }
        }
        return nil
    }
    
    func higlighted(words: [String], attributes: [NSAttributedStringKey: Any]) -> NSMutableAttributedString {
        
        let allAttributedText = NSMutableAttributedString.init(string: self)
        var ranges = [NSRange]()
        
        for word in words {
            var string = allAttributedText.string as NSString
            var i = 0
            while true {
                var range = string.range(of: word)
                if range.location == NSNotFound {
                    break
                }
                i += range.location + word.count
                string = string.substring(from: range.location + range.length) as NSString
                range.location = i - word.count
                print("\(range)  XX \(word)" )
                
                ranges.append(range)
            }
        }
        for range in ranges {
            allAttributedText.addAttributes(attributes, range: range)
        }
        return allAttributedText
    }
    
    func getAddressFormat(length: Int = 6) -> String {
        let header = String(self.prefix(length))
        let footer = String(self.suffix(length))
        return "\(header)...\(footer)"
    }
    
    func textWidth(font: UIFont) -> CGFloat {
        let attributes = [NSAttributedStringKey.font: font]
        return self.size(withAttributes: attributes).width
    }
    
}

