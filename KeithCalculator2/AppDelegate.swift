//
//  AppDelegate.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit
@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        window!.rootViewController = CalculatorProtraitViewController()
        window!.makeKeyAndVisible()
        return true
    }
}

