//
//  AppDelegate.swift
//  Giphy Demo
//
//  Created by Roman on 11.04.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        let rootVC = MainScreenViewController.make()
        window.rootViewController = rootVC
        window.makeKeyAndVisible()
        return true
    }
}

