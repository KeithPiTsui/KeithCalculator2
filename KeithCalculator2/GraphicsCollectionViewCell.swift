
//
//  KeypadCollectionViewCell.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

final class GraphicsCollectionViewCell: UICollectionViewCell {
    
    /// Graphic Drawer for generating formula graphic image
    private let graphicDrawer = FormulaGraphicDrawer()
    
    /// for holding formula graphic
    private weak var graphicView: UIImageView!
    
    /// for indicating generating formula graphic
    private weak var activityIndicator: UIActivityIndicatorView!
    
    /// for storing the input expression
    var inputExpression: String = "" {
        didSet{
            self.activityIndicator.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                let image = self.graphicDrawer.getFormulaGraphicImageWithFormulaString(self.inputExpression, withSize: self.bounds.size, andScale: 5.0)
                dispatch_async(dispatch_get_main_queue()){
                    self.graphicView.image = image
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    // MARK -- Collection View Cell customizing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 3
        
        let view = UIImageView()
        graphicView = view
        graphicView.backgroundColor = UIColor.whiteColor()
        graphicView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        
        let v = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator = v
        activityIndicator.tag = 1001
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(v)
        
        NSLayoutConstraint.activateConstraints(getConstraints())
        
    }
    
    /// helper function for generating constraints needed for this cell's layout
    private func getConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: graphicView, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: activityIndicator, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        return constraints
    }
    
    /// required initializer hasn't implemented yet
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}