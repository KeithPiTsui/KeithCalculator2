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
    
    private let graphicDrawer = FormulaGraphicDrawer()
    
    // an input expression for graphing view to draw a formula graphic on x-y plate
    private var inputExpression: String
    
    /// initialize with an expression string
    init(WithExpression exp: String) {
        inputExpression = exp
        super.init(nibName: nil, bundle: nil)
    }
    
    /// required initializer that hasn't implemented yet
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
    
    /// Formula Graphic generating indicator
    private weak var activityIndicator: UIActivityIndicatorView! {
        didSet{
            activityIndicator.tag = 1001
            activityIndicator.hidesWhenStopped = true
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.sizeToFit()
        }
    }
    
    /// An UIImage View for holding formula graphic
    private weak var graphicView: UIImageView! {
        didSet{
            graphicView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// A stepper controlling the scale of formula graphic
    private weak var zoomer:UIStepper!{
        didSet{
            zoomer.translatesAutoresizingMaskIntoConstraints = false
            zoomer.value = 1
            zoomer.addTarget(self, action: #selector(DrawingViewController.zoom(_:)), forControlEvents: .ValueChanged)
            zoomer.minimumValue = 1
            zoomer.maximumValue = 10
            zoomer.stepValue = 1
        }
    }
    
    /**
     dismiss presentation
     */
    func closePresentation() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     get zoomer's zoom in or zoom out event, and change graphic accordingly
     */
    func zoom(stepper: UIStepper) {
        scale = CGFloat(stepper.value)
        loadFormulaGraphic()
    }
    
    private var scale: CGFloat = 1
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    // MARK: - UIViewController life cycle
    override func loadView() {
        //self.view = UIImageView()
        self.view = UIView()
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewDidLoad() {
        
        let gv = UIImageView()
        graphicView = gv
        view.addSubview(gv)
        
        let v = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator = v
        view.addSubview(v)
        
        let btn = UIButton()
        menuButton = btn
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(DrawingViewController.closePresentation), forControlEvents: .TouchUpInside)
        
        let stepper = UIStepper()
        zoomer = stepper
        view.addSubview(stepper)

        NSLayoutConstraint.activateConstraints(getContraints())
        
    }
    
    /// A helper function that generates needed constraints
    private func getContraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Top, relatedBy: .Equal, toItem: topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 8))
        constraints.append(NSLayoutConstraint(item: menuButton, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: zoomer, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .RightMargin, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: zoomer, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .BottomMargin, multiplier: 1, constant: -8))
        
        constraints.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        return constraints
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadFormulaGraphic()
    }
    
    /// Using another queue on another thread to generate formula graphic
    private func loadFormulaGraphic() {
        self.activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
            let image = self.graphicDrawer.getFormulaGraphicImageWithFormulaString(self.inputExpression, withSize: self.view.bounds.size, andScale: self.scale)
            dispatch_async(dispatch_get_main_queue()){
                self.graphicView.image = image
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        loadFormulaGraphic()
    }
}
