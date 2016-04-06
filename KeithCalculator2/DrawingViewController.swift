//
//  DrawingViewController.swift
//  KeithCalculator2
//
//  Created by Pi on 4/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - A view controller for control how to use formular graphing view
final class DrawingViewController: UIViewController {
    
    // an input expression for graphing view to draw a formula graphic on x-y plate
    private var inputExpression: String
    
    init(WithExpression exp: String) {
        inputExpression = exp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** 
     A button for dismiss presenting view controller
    */
    private weak var menuButton: UIButton! {
        didSet{
            menuButton.translatesAutoresizingMaskIntoConstraints = false
            menuButton.setTitle("X", forState: .Normal)
            menuButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            menuButton.sizeToFit()
        }
    }
    
    func closePresentation() { self.dismissViewControllerAnimated(true, completion: nil) }
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    // MARK: - UIViewController life cycle
    override func loadView() {
        self.view = DrawingView()
        let v = self.view as! DrawingView
        v.myFunctionInputTest = inputExpression
        v.backgroundColor = UIColor.whiteColor()
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
    
    
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        self.view.setNeedsDisplay()
    }
}
