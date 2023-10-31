//
//  MenuCell.swift
//  StandByMode
//
//  Created by Coder ACJHP on 31.10.2023.
//

import Foundation
import UIKit

class MenuCell: UICollectionViewCell {
    
    static let darkestGray = UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1.0)
    static let reusableIdentifier = String(describing: MenuCell.self)
    
    override var isSelected: Bool {
        didSet {
            
            backgroundColor = isSelected ? .darkGray : MenuCell.darkestGray
        }
    }
            
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.minimumScaleFactor = 0.9
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            separatorLine.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(withTrack track: Track, isLast: Bool = false) {
        titleLabel.text = track.title
        separatorLine.isHidden = isLast
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        backgroundColor = MenuCell.darkestGray
    }
}
