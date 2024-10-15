//
//  GlyphView.swift
//  StandByMode
//
//  Created by Coder ACJHP on 16.10.2024.
//

import Foundation
import UIKit

class GlyphView: UIView {
    
    private var digit: Int = .zero {
        didSet {
            guard oldValue != digit else { return }
            
            // Animate text chages
            var perspective = CATransform3DIdentity
            perspective.m34 = 1 / -200
            self.layer.transform = perspective
            let rotate = CABasicAnimation(keyPath: "transform.rotation.y")
            rotate.fromValue = 0
            rotate.byValue = CGFloat.pi * 2
            rotate.duration = 1
            rotate.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            // add animation
            self.layer.add(rotate, forKey: "opacity")
        }
    }
    private var digitColor: UIColor = .white
    private let font = UIFont(name: "OPTIPrisma-Caps", size: 80) ?? .boldSystemFont(ofSize: 80)
    
    
    init(frame: CGRect, digit: Int) {
        self.digit = digit
        super.init(frame: frame)
        self.backgroundColor = .black
    }
    
    init(frame: CGRect, digit: Int, digitColor: UIColor, backgroundColor: UIColor) {
        self.digit = digit
        self.digitColor = digitColor
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoder initializer not handled!")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setNeedsDisplay()
    }
    
    public func updateDigit(number: Int) {
        self.digit = number
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw background
        backgroundColor?.setFill()
        let backgroundPath = UIBezierPath(rect: rect)
        backgroundPath.fill()
        
        // Draw digit
        
        let string = String(digit)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let fontSize = fontSizeThatFits(width: rect.width, text: string)
        
        let attrs: [NSAttributedString.Key : Any] = [
            .foregroundColor: digitColor,
            .font: font.withSize(fontSize),
            .paragraphStyle: paragraphStyle
        ]
        
        
        let size = string.size(withAttributes: attrs)
        let stringRect = CGRect(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
        string.draw(in: stringRect, withAttributes: attrs)
    }
    
    // MARK: - Helpers
    
    func fontSizeThatFits(width: CGFloat, text: String) -> CGFloat {
        var minFontSize: CGFloat = 1
        var maxFontSize: CGFloat = 1000
        var fontSize: CGFloat = (minFontSize + maxFontSize) / 2

        while minFontSize < maxFontSize - 1 {
            let font = UIFont(name: "OPTIPrisma-Caps", size: fontSize)!
            let size = text.size(withAttributes: [.font: font])
            
            if size.width > width {
                maxFontSize = fontSize
            } else {
                minFontSize = fontSize
            }
            
            fontSize = (minFontSize + maxFontSize) / 2
        }
        
        return fontSize
    }

}
