//
//  DrawingViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 4/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    override func loadView() {
        self.view = DrawingView()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
}
