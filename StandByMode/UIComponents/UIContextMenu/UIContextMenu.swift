//
//  UIContextMenu.swift
//  StandByMode
//
//  Created by Onur Işık on 23.04.2019.
//  Copyright © 2019 Coder ACJHP. All rights reserved.
//
import Foundation
import UIKit

protocol UIContextMenuDelegate: AnyObject {
    func contextMenu(_ contextMenu: UICContextMenu?, didSelectTrack track: Track)
    func contextMenu(_ contextMenu: UICContextMenu?, didCancelled: Bool)
}

class UICContextMenu: UIView, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var shadowView: UIView!
    private var contextMenu: UIView!
    private let posiY: CGFloat = 50
    private let contextMenuWidth: CGFloat = 280
    private let contextMenuHeight: CGFloat = 340
    private let preferredCellHeight: CGFloat = 45
    private var tracks: Array<Track> = []
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: MenuCell.reusableIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = false
        collectionView.frame = CGRect(x: 0, y: 0, width: contextMenuWidth, height: contextMenuHeight)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
        
    private weak var containerController: UIViewController? = nil
    private var feedbackGenerator: UIImpactFeedbackGenerator? = nil
    
    private lazy var ExpandedRect: CGRect =  {
        return CGRect(
            x: self.frame.width / 2 - contextMenuWidth / 2,
            y: self.frame.height - contextMenuHeight - posiY,
            width: contextMenuWidth,
            height: contextMenuHeight
        )
    }()
    
    public weak var delegate: UIContextMenuDelegate?
    
    init(onViewController: UIViewController, trackList: Array<Track>) {
        super.init(frame: onViewController.view.bounds)
        containerController = onViewController
        tracks = trackList
                
        feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedbackGenerator!.prepare()
        
        shadowView = UIView(frame: self.bounds)
        shadowView.tag = 1000
        shadowView.backgroundColor = UIColor.init(white: 0.2, alpha: 0.7)
        
        let tapAction = #selector(handleTap(_:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapAction)
        tapGesture.delegate = self
        shadowView.addGestureRecognizer(tapGesture)
        
        contextMenu = UIView(frame: ExpandedRect)
        contextMenu.backgroundColor = MenuCell.darkestGray
        contextMenu.center.x = onViewController.view.center.x
        contextMenu.layer.cornerRadius = 10
        contextMenu.layer.masksToBounds = true
        shadowView.addSubview(contextMenu)
        
        contextMenu.addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func showContextMenu(sender: UIButton? = nil) {
        
        guard let containerController else { return }
        containerController.view.addSubview(shadowView)
        
        if let sender {
            let convertedRect = sender.superview!.convert(sender.frame, to: shadowView)
            self.contextMenu.frame.origin = CGPoint(
                x: convertedRect.maxX - contextMenuWidth,
                y: convertedRect.maxY - (contextMenuHeight + sender.frame.height)
            )
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 1,
            options: .curveEaseIn,
            animations: {
                
                self.shadowView.alpha = 1.0
                self.feedbackGenerator?.impactOccurred()
                
            }, completion: nil
        )
    }
    
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        
        guard let tappedView = gestureRecognizer.view else { return }
        
        if tappedView.tag == shadowView.tag {
            removeContextMenu()
        }
    }
    
    
    fileprivate func removeContextMenu() {
        
        UIView.transition(
            with: shadowView,
            duration: 0.3,
            options: .curveEaseOut,
            animations: {
                
                self.shadowView.alpha = .zero
            }
        ) { (_) in
            self.shadowView.removeFromSuperview()
        }
    }
    
    func setSelectedItem(_ index: Int) {
        collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredVertically)
    }
    
    // Best comparition way to detect tapped view (for subviews)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: preferredCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.reusableIdentifier, for: indexPath) as? MenuCell else {
            return UICollectionViewCell()
        }
        let track = tracks[indexPath.item]
        let isLast = (tracks.count - 1 == indexPath.item)
        cell.configure(withTrack: track, isLast: isLast)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTrack = tracks[indexPath.item]
        delegate?.contextMenu(self, didSelectTrack: selectedTrack)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.removeContextMenu()
        }
    }
}
