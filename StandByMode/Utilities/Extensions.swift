//
//  Extensions.swift
//  StandByMode
//
//  Created by Coder ACJHP on 1.11.2023.
//

import Foundation
import UIKit

extension UIColor {
    
    static func random(hue: CGFloat = CGFloat.random(in: 0...1),
                       saturation: CGFloat = CGFloat.random(in: 0.5...1), // from 0.5 to 1.0 to stay away from white
                       brightness: CGFloat = CGFloat.random(in: 0.5...1), // from 0.5 to 1.0 to stay away from black
                       alpha: CGFloat = 1) -> UIColor {
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    /**
     Create UIColor object from hex value.
     
     - property hexString: It string with you color name in hex. It been look like it "#ffffff".
     */
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}

extension StringProtocol {
    func nsRange<S: StringProtocol>(of string: S, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> NSRange? {
        self.range(of: string,
                   options: options,
                   range: range ?? startIndex..<endIndex,
                   locale: locale ?? .current)?
            .nsRange(in: self)
    }
    func nsRanges<S: StringProtocol>(of string: S, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> [NSRange] {
        var start = range?.lowerBound ?? startIndex
        let end = range?.upperBound ?? endIndex
        var ranges: [NSRange] = []
        while start < end,
              let range = self.range(of: string,
                                     options: options,
                                     range: start..<end,
                                     locale: locale ?? .current) {
            ranges.append(range.nsRange(in: self))
            start = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return ranges
    }
}

extension String {
    /// Substring from `NSRange`
    ///
    /// - Parameter nsRange: `NSRange` within the string.
    /// - Returns: `Substring` with the given `NSRange`, or `nil` if the range can't be converted.
    
    subscript(nsRange: NSRange) -> Substring? {
        return Range(nsRange, in: self)
            .flatMap { self[$0] }
    }
    
    func substringAfterLastOccurenceOf(_ char: Character) -> String {
        
        let regex = try? NSRegularExpression(pattern: "\(char)\\s*(\\S[^\(char)]*)$")
        if let match = regex?.firstMatch(in: self, range: NSRange(startIndex ..< endIndex, in: self)), let result = self[match.range(at: 1)] {
            return String(result)
        }
        return ""
    }
    
}
