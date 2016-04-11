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

    let picNames = ["SCTA.png","SCLog.png","SCFSGraphic.png","SCGraphing.png","SCCFUsage.png","SCCF.png","SCOTS.png"]

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow()
        window!.rootViewController = CalculatorViewController()
        //window!.rootViewController = pvc
        
        window!.rootViewController?.view.backgroundColor = UIColor.whiteColor()
        window!.makeKeyAndVisible()
        
        return true
    }
}

extension AppDelegate: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let pic = (viewController as! DemoViewController).picName
        let ix = picNames.indexOf(pic)! - 1
        if ix < 0 {
            return nil
        }
        
        return DemoViewController(Demo: picNames[ix])
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let pic = (viewController as! DemoViewController).picName
        let ix = picNames.indexOf(pic)! + 1
        if ix >= picNames.count {
            return nil
        }
        
        return DemoViewController(Demo: picNames[ix])
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return picNames.count
    }
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        let page = pageViewController.viewControllers![0] as! DemoViewController
        let picName = page.picName
        return picNames.indexOf(picName)!
    }
}

