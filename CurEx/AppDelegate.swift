//
//  AppDelegate.swift
//  CurEx
//
//  Created by Артем Щербаков on 16.07.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let navigation = UINavigationController()
        let curExView = CurExView()
        navigation.viewControllers = [curExView]
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
}

