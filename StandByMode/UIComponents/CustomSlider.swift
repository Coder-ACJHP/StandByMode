//
//  CustomSlider.swift
//  StandByMode
//
//  Created by Coder ACJHP on 1.11.2023.
//

import Foundation
import UIKit

class CustomSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 3
    
    @IBInspectable var thumbRadius: CGFloat = 15
    
    // Custom thumb view which will be converted to UIImage
    // and set as thumb. You can customize it's colors, border, etc.
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = .white//thumbTintColor
        thumb.layer.borderWidth = 0.4
        thumb.layer.borderColor = UIColor.darkGray.cgColor
        return thumb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
        setThumbImage(thumb, for: .highlighted)
    }
    
    private func thumbImage(radius: CGFloat) -> UIImage {
        // Set proper frame
        // y: radius / 2 will correctly offset the thumb
        
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2
        
        // Convert thumbView to UIImage
        // See this: https://stackoverflow.com/a/41288197/7235585
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        // Set custom track height
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
}
