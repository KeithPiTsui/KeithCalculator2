
//
//  KeypadCollectionViewCell.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

final class GraphicsCollectionViewCell: UICollectionViewCell {
    
    private let graphicDrawer = FormulaGraphicDrawer()
    
    private weak var graphicView: UIImageView!
    private weak var activityIndicator: UIActivityIndicatorView!
    
    var inputExpression: String = "" {
        didSet{
            self.activityIndicator.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                let image = self.graphicDrawer.getFormulaGraphicImageWithFormulaString(self.inputExpression, withSize: self.bounds.size, andScale: 5.0)
                //let syntaxCorrect = self.graphicDrawer.formulaSyntaxCorrect
                dispatch_async(dispatch_get_main_queue()){
                    self.graphicView.image = image
                    self.activityIndicator.stopAnimating()
//                    if !syntaxCorrect {
//                        NSNotificationCenter.defaultCenter().postNotificationName("Syntax Error", object: nil)
//                    } else {
//                        NSNotificationCenter.defaultCenter().postNotificationName("Draw Done", object: nil)
//                    }
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
        view.backgroundColor = UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        
        contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
        
        let v = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        v.tag = 1001
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(v)
        activityIndicator = v
        contentView.addConstraint(NSLayoutConstraint(item: v, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: v, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}