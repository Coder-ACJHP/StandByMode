//
//  SlidingContainerViewController.swift
//  StandByMode
//
//  Created by Coder ACJHP on 1.11.2023.
//

import Foundation
import UIKit

// MARK: - Protocol

class SlidingContainerViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    private lazy var flipClockViewController: FlipClockViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FlipClockViewController") as! FlipClockViewController
        return viewController
    }()
    
    private lazy var digitalClockViewController: DigitalClockViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DigitalClockViewController") as! DigitalClockViewController
        return viewController
    }()
    
    private lazy var halfAlphaViewController: CrockedCharsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HalfAlphaViewController") as! CrockedCharsViewController
        return viewController
    }()
    
    private lazy var linesClockViewController: LinesClockViewController = {
        return LinesClockViewController()
    }()
    
    private lazy var calendarClockViewController: CalendarClockViewController = {
        return CalendarClockViewController()
    }()
    
    var individualPageViewControllerList = [UIViewController]()
    
    // MARK: - Lifecycle
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation)
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        delegate = self
        dataSource = self
        
        individualPageViewControllerList = [
            linesClockViewController,
            flipClockViewController,
            digitalClockViewController,
            halfAlphaViewController,
            calendarClockViewController
        ]
                
        setViewControllers([individualPageViewControllerList[0]], direction: .forward, animated: true, completion: nil)
        
        // Prevent screen lock
        UIApplication.shared.isIdleTimerDisabled = true
        // Decrease screen brigtness
        UIScreen.main.brightness = 0.0
    }
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    // MARK: - Delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let indexOfCurrentPageViewController = individualPageViewControllerList.firstIndex(of: viewController)!
        if indexOfCurrentPageViewController == 0 {
            return nil // To show there is no previous page
        } else {
            // Previous UIViewController instance
            return individualPageViewControllerList[indexOfCurrentPageViewController - 1]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let indexOfCurrentPageViewController = individualPageViewControllerList.firstIndex(of: viewController)!
        if indexOfCurrentPageViewController == individualPageViewControllerList.count - 1 {
            return nil // To show there is no next page
        } else {
            // Next UIViewController instance
            return individualPageViewControllerList[indexOfCurrentPageViewController + 1]
        }
    }
}
