//
//  DayCell.swift
//  StandByMode
//
//  Created by Coder ACJHP on 2.11.2023.
//

import Foundation
import UIKit

class DayCell: UICollectionViewCell {
    
    static let reusableIdentifier = String(describing: DayCell.self)
    
    override var isSelected: Bool {
        didSet {
            dayLabel.textColor = isSelected ? .white : .darkGray
            dayLabel.backgroundColor = isSelected ? .red : .clear
        }
    }
    
    private let dayLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: .init(width: 55, height: 55)))
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.layer.cornerRadius = label.frame.height / 2
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initCommon()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initCommon()
    }
    
    private final func initCommon() {
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(dayLabel)
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dayLabel.layer.cornerRadius = dayLabel.frame.height / 2
        dayLabel.layer.masksToBounds = true
    }
    
    func configure(with text: String) {
        dayLabel.text = text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dayLabel.text = nil
    }
}
