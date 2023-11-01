//
//  AppDelegate.swift
//  StandByMode
//
//  Created by Coder ACJHP on 27.10.2023.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let initialVC = SlidingContainerViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()

        return true
    }

}

