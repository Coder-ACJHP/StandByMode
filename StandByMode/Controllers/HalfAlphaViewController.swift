//
//  HalfAlphaViewController.swift
//  StandByMode
//
//  Created by Coder ACJHP on 1.11.2023.
//

import UIKit

class HalfAlphaViewController: UIViewController {
    
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
            rotateGlyphs()
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

    private var counter = 0
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
        
        amPMLabel.font = font.withSize(200)
        amPMLabel.textColor = colorList.randomElement()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawText() {
        
        hStackView.arrangedSubviews.forEach({
            hStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        })
        
        let characters = Array(drawingText)
        
        for (index, char) in characters.enumerated() {
            
            let drawingText = String(char)
            let isSeparator = (drawingText == ":")
            let foregroundColor: UIColor = isSeparator ? (lastBlinkedColor == .white ? .clear : .white) : colorList[index]
            
            let label = UILabel(frame: .zero)
            label.font = font
            label.textAlignment = .center
            label.text = drawingText
            label.minimumScaleFactor = 0.95
            label.textColor = foregroundColor
            
            hStackView.addArrangedSubview(label)
            label.sizeToFit()
            
            if isSeparator {
                lastBlinkedColor = foregroundColor
            }
        }
    }

    private final func rotateGlyphs() {
        
        let visibleLabels = hStackView.arrangedSubviews.compactMap({ $0 as? UILabel })
        
        for (index, label) in visibleLabels.enumerated() {
                
            let rotationAngle = rotationAngles[index]
            label.transform = label.transform.rotated(by: rotationAngle)
        }
    }
}
