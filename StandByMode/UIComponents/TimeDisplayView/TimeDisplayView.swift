//
//  TimeDisplayView.swift
//  StandByMode
//
//  Created by Coder ACJHP on 16.10.2024.
//

import Foundation
import UIKit

// Container view to display multiple digits side by side
class TimeDisplayView: UIStackView {
    
    // Initialize with an array of digits
    init(digits: [Int]) {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        spacing = 5
        
        for digit in digits {
            let digitView = GlyphView(frame: .zero, digit: digit)
            addArrangedSubview(digitView)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateTime(digits: [Int]) {
        // Get subview as Glyph view to update drawing
        let glyphs = self.arrangedSubviews.compactMap({ $0 as? GlyphView })
        for (index, glyphView) in glyphs.enumerated() {
            glyphView.updateDigit(number: digits[index])
        }
    }
}
