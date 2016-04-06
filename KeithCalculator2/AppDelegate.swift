//
//  AppDelegate.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit
import SafariServices
@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        window!.rootViewController = CalculatorViewController()
        //window!.rootViewController = DrawingViewController()
        //window!.rootViewController = SQLiteViewController()
        window!.rootViewController?.view.backgroundColor = UIColor.whiteColor()
        window!.makeKeyAndVisible()
        
        return true
    }
}

