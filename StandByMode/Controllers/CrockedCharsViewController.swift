//
//  CrockedCharsViewController.swift
//  StandByMode
//
//  Created by Coder ACJHP on 1.11.2023.
//

import UIKit

class CrockedCharsViewController: UIViewController {
    
    private var crockedCharsView: CrockedCharsView!

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "hh:mm"
        return formatter
    }()
    
    private var updateTimer: Timer? = nil
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crockedCharsView = CrockedCharsView(frame: view.bounds)
        view.addSubview(crockedCharsView)
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
    
    private final func updateUI() {
        
        guard updateTimer == nil else { return }
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            let today = Date()
            self.dateFormatter.dateFormat = "hh:mm"
            self.crockedCharsView.drawingText = self.dateFormatter.string(from: today)
            self.dateFormatter.dateFormat = "a"
            self.crockedCharsView.hourType = self.dateFormatter.string(from: today)
                        
        }
        updateTimer?.fire()
    }

}

class CrockedCharsView: UIView {
    
    public var drawingText: String = "" {
        didSet {
            drawText()
        }
    }
    
    public var hourType: String = "" {
        didSet {
            amPMLabel.text = hourType
        }
    }
    
    private let hStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = .zero
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 40, bottom: 10, right: 40)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let amPMLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorList: Array<UIColor> = [
        UIColor(hexString: "#0793fe"),
        UIColor(hexString: "#8ff3bc"),
        UIColor(hexString: "#ffffff"),
        UIColor(hexString: "#52d7fa"),
        UIColor(hexString: "#08966e")
    ]
    
    private let rotationAngles: Array<CGFloat> = [
        CGFloat.pi / 30,
        CGFloat.pi / -30,
        CGFloat.pi / 360,
        CGFloat.pi / -40,
        CGFloat.pi / 40
    ]

    private var oldCharCount = 0
    private var lastBlinkedColor: UIColor = .white
    private let font = UIFont(name: "octopuss", size: 450)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        addSubview(hStackView)
        NSLayoutConstraint.activate([
            hStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -50),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            hStackView.heightAnchor.constraint(equalToConstant: frame.height / 1.9),
        ])
        
        addSubview(amPMLabel)
        NSLayoutConstraint.activate([
            amPMLabel.topAnchor.constraint(equalTo: hStackView.bottomAnchor, constant: -10),
            amPMLabel.centerXAnchor.constraint(equalTo: hStackView.centerXAnchor),
            amPMLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 1),
            amPMLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
        ])
        
        amPMLabel.font = font.withSize(150)
        amPMLabel.textColor = colorList.randomElement()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawText() {
        
        let characters = Array(drawingText)
        // Update ui only if there any difference
        guard characters.count != oldCharCount else {
            updateText(withCharArray: characters)
            return
        }
        
        // Cleanup old labels
        hStackView.arrangedSubviews.forEach({
            hStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        for (index, char) in characters.enumerated() {
            
            let drawingText = String(char)
            
            let label = UILabel(frame: .zero)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.textColor = colorList[index]
            label.font = font
            label.text = drawingText
            label.minimumScaleFactor = 0.8
            label.adjustsFontSizeToFitWidth = true
            
            hStackView.addArrangedSubview(label)
            label.sizeToFit()
        }
        
        // Make letters crocked
        rotateGlyphs()
        
        // Store last char counts
        oldCharCount = characters.count
    }

    private final func rotateGlyphs() {
        
        let visibleLabels = hStackView.arrangedSubviews.compactMap({ $0 as? UILabel })
        
        for (index, label) in visibleLabels.enumerated() {
                
            let rotationAngle = rotationAngles[index]
            label.transform = label.transform.rotated(by: rotationAngle)
        }
    }
    
    private final func updateText(withCharArray arr: Array<String.Element>) {
        
        let blinkingLabelIndex = 2
        
        let visibleLabels = hStackView.arrangedSubviews.compactMap({ $0 as? UILabel })
        
        for (index, label) in visibleLabels.enumerated() {
                
            label.text = String(arr[index])
            
            // animate dot apperience
            if index == blinkingLabelIndex {
                let foregroundColor: UIColor = (lastBlinkedColor == .white) ? .clear : .white
                label.textColor = foregroundColor
                lastBlinkedColor = foregroundColor
            }
        }
    }
}
