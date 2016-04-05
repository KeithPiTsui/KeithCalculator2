//
//  DrawingViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 4/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

class DrawingViewController: UIViewController {
    
    private var inputExpression: String
    
    init(WithExpression exp: String) {
        inputExpression = exp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private weak var menuButton: UIButton! {
        didSet{
            menuButton.translatesAutoresizingMaskIntoConstraints = false
            menuButton.setTitle("X", forState: .Normal)
            menuButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            menuButton.sizeToFit()
        }
    }
    
    override func loadView() {
        self.view = DrawingView()
        let v = self.view as! DrawingView
        v.myFunctionInputTest = inputExpression
        view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        let btn = UIButton()
        menuButton = btn
        view.addSubview(btn)
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 8))
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        NSLayoutConstraint.activateConstraints(constraints)
        btn.addTarget(self, action: #selector(DrawingViewController.closePresentation), forControlEvents: .TouchUpInside)
    }
    
    func closePresentation() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        print("traitChanged")
        self.view.setNeedsDisplay()
    }
}
