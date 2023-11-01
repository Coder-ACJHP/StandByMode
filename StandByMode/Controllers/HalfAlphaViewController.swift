//
//  HalfAlphaViewController.swift
//  StandByMode
//
//  Created by Coder ACJHP on 1.11.2023.
//

import UIKit

class HalfAlphaViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
    
    private var lastColor: UIColor = .white
    private let blinkPattern = ":"
    private var updateTimer: Timer? = nil
    private let colorList: Array<UIColor> = [
        UIColor(hexString: "#0793fe"),
        UIColor(hexString: "#8ff3bc"),
        UIColor(hexString: "#d9e5ec"),
        UIColor(hexString: "#52d7fa"),
        UIColor(hexString: "#08966e")
    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override  func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
        updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let updateTimer {
            updateTimer.invalidate()
            self.updateTimer = nil
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
    
    // MARK: - Helpers
    
    private final func colorizeTimeText() {
        
        guard let text = timeLabel.text else { return }
        
        let attributedText = NSMutableAttributedString(string: text)
        
        let characterList = Array(text)
        
        for (index, char) in characterList.enumerated() {
            
            if let charRange = text.nsRange(of: String(char)) {
            
                if String(char) == blinkPattern {
                    let color: UIColor = (lastColor == .white) ? .black : .white
                    attributedText.addAttribute(.foregroundColor, value: color, range: charRange)
                    lastColor = color
                } else {
                    let color = colorList[index]
                    attributedText.addAttribute(.foregroundColor, value: color, range: charRange)
                }
            }
        }
        
        timeLabel.attributedText = attributedText
    }
    
    private final func updateUI() {
        
        guard updateTimer == nil else { return }
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            let today = Date()
            self.timeLabel.text = self.dateFormatter.string(from: today)
            
            self.colorizeTimeText()
            
        }
        updateTimer?.fire()
    }

}
