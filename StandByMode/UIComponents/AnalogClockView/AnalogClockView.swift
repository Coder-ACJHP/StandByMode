//
//  AnalogClockView.swift
//  StandByMode
//
//  Created by Coder ACJHP on 2.11.2023.
//

import UIKit

class AnalogClockView: UIView {
    
    // Custom clock hand graphics
    let hourHandPath: UIBezierPath = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 6, y: 0))
        path.addLine(to: CGPoint(x: 1, y: -120))
        path.addLine(to: CGPoint(x: -1, y: -120))
        path.addLine(to: CGPoint(x: -6, y: 0))
        path.close()
        return path
    }()

    let minuteHandPath: UIBezierPath = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 4, y: 0))
        path.addLine(to: CGPoint(x: 1, y: -160))
        path.addLine(to: CGPoint(x: -1, y: -160))
        path.addLine(to: CGPoint(x: -4, y: 0))
        path.close()
        return path
    }()

    let secondHandPath: UIBezierPath = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 2, y: 0))
        path.addLine(to: CGPoint(x: 1, y: -200))
        path.addLine(to: CGPoint(x: -1, y: -200))
        path.addLine(to: CGPoint(x: -2, y: 0))
        path.close()
        return path
    }()
    
    private let calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.locale = Locale.current
        c.timeZone = TimeZone.current
        return c
    }()
    
    private var updateTimer: Timer? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initCommon()
    }
    
    private func initCommon() {
        
        guard updateTimer == nil else { return }
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        // Clear screen
        context?.setFillColor(UIColor.black.cgColor)
        context?.fill(rect)
        
        // Draw the border
//        drawClockBorder(inRect: rect, color: .white)
        
        // Draw the hour numbers
        drawHourNumbers(inRect: rect)

        // Draw the minute and second ticks
        drawTicks(inRect: rect)
        
        // Draw the text
        drawTextOnClock(inRect: rect, text: "Coder ACJHP")
        
        // Draw the hands
        drawClockHands(inRect: rect)
        
        // Draw a small circle at center of the clock
        drawClockCenterCircle(inRect: rect, color: .red)
    }
    
    // MARK: - Helpers
    
    private final func drawClockBorder(inRect rect: CGRect, color: UIColor) {
        
        let context = UIGraphicsGetCurrentContext()
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - 50
        
        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(4.0)
        context?.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        context?.strokePath()
    }
    
    func drawHourNumbers(inRect rect: CGRect) {
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - 30
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 20),
        ]
        
        for hour in 1...12 {
            let hourText = NSAttributedString(string: "\(hour)", attributes: textAttributes)
            let hourAngle = Double(hour) / 12.0 * 2 * .pi - .pi / 2
            
            let textSize = hourText.size()
            let textX = center.x + radius * 0.8 * CGFloat(cos(hourAngle)) - textSize.width / 2
            let textY = center.y + radius * 0.8 * CGFloat(sin(hourAngle)) - textSize.height / 2
            
            hourText.draw(at: CGPoint(x: textX, y: textY))
        }
    }
    
    func drawTicks(inRect rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - 52
        
        for minute in 0..<60 {
            let minuteAngle = Double(minute) / 60.0 * 2 * .pi - .pi / 2
            let startX = center.x + (radius - 10) * CGFloat(cos(minuteAngle))
            let startY = center.y + (radius - 10) * CGFloat(sin(minuteAngle))
            let endX = center.x + radius * CGFloat(cos(minuteAngle))
            let endY = center.y + radius * CGFloat(sin(minuteAngle))
            
            context?.move(to: CGPoint(x: startX, y: startY))
            context?.addLine(to: CGPoint(x: endX, y: endY))
            
            let color = minute % 5 == 0 ? UIColor.white.cgColor : UIColor.lightGray.cgColor
            context?.setStrokeColor(color)
            let thickness = minute % 5 == 0 ? 3.0 : 2.0
            context?.setLineWidth(thickness)
            
            context?.strokePath()
        }
    }
    
    private func degreeToRadian(angle: CGFloat) -> CGFloat {
        angle / 180 * CGFloat.pi
    }
    
    // Draw all hands for clock
    
    private final func drawClockHands(inRect rect: CGRect) {
                
        let components = calendar.dateComponents([.hour, .minute, .second], from: Date())
        
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        // Calculate positions for the clock hands based on the time
        let singleStepDegree = CGFloat(minute) * (1.0 / 60.0)
        let hourDegree = CGFloat(hour) * (360.0 / 12.0) + singleStepDegree * (360.0 / 12.0)
        let hourAngle = degreeToRadian(angle: hourDegree)
        let minuteAngle = degreeToRadian(angle: CGFloat(minute) * (360.0 / 60.0))
        let secondAngle = degreeToRadian(angle: CGFloat(second) * (360.0 / 60.0))

        // Draw the clock hands using UIBezierPath
        drawClockHand(inRect: rect, handPath: hourHandPath, atAngle: hourAngle, color: .lightGray, width: 4.0)
        drawClockHand(inRect: rect, handPath: minuteHandPath, atAngle: minuteAngle, color: .white, width: 3.0)
        drawClockHand(inRect: rect, handPath: secondHandPath, atAngle: secondAngle, color: .red, width: 2.0)
    }
       
    // Draw single hand function
    
    private final func drawClockHand(inRect rect: CGRect, handPath: UIBezierPath, atAngle angle: Double, color: UIColor, width: CGFloat) {
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        
        context?.translateBy(x: rect.width / 2, y: rect.height / 2)
        context?.rotate(by: CGFloat(angle))
        context?.translateBy(x: -handPath.bounds.midX, y: -handPath.bounds.maxY)
        
        handPath.lineCapStyle = .round
        handPath.lineJoinStyle = .round
        handPath.lineWidth = 1
        UIColor.darkGray.set()
        handPath.stroke()
        handPath.lineWidth = width
        color.set()
        handPath.fill()
        
        context?.restoreGState()
    }
    
    private final func drawTextOnClock(inRect rect: CGRect, text: String) {
        
        let posiX = rect.width / 2
        let posiY = rect.height * 0.4
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .black),
        ]
        
        let brandName = NSAttributedString(string: "\(text)", attributes: textAttributes)
        let position = CGPoint(x: posiX - brandName.size().width / 2, y: posiY)
        brandName.draw(at: position)
    }
    
    private final func drawClockCenterCircle(inRect rect: CGRect, color: UIColor) {
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.saveGState()
        
        let size = CGSize(width: 20, height: 20)
        let origin = CGPoint(x: (rect.width / 2) - (size.width / 2), y: (rect.height / 2) - (size.height / 2))
        
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: origin, size: size))
        color.set()
        circlePath.fill()
        
        context?.restoreGState()
    }
    
    // MARK: - Public functions
    
    public func startClock() {
        
        initCommon()
        
        if let updateTimer {
            updateTimer.fire()
        }
    }
    
    public func stopClock() {
        
        if let updateTimer {
            updateTimer.invalidate()
            self.updateTimer = nil
        }
    }

}
