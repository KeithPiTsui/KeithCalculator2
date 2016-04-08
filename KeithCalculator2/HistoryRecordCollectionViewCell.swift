//
//  KeypadCollectionViewCell.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - a customized cell of collection view cell for display history of input expression on a list (table view)
final class HistoryRecordCollectionViewCell: UICollectionViewCell {
    
    /**
     a table view as a list for displaying historical input expression
     */
    var historyViewer: UITableView! {
        willSet{
            if !tableViewConstraints.isEmpty {
                // deactivate the previous constraints for previous table
                NSLayoutConstraint.deactivateConstraints(tableViewConstraints)
                // clear all previous constraints
                tableViewConstraints.removeAll()
            }
            
            // remove previous table view
            if historyViewer != nil {
                historyViewer.removeFromSuperview()
            }
        }
        
        didSet{
            // customize table
            historyViewer.translatesAutoresizingMaskIntoConstraints = false
            
            // add into view hierarchy
            contentView.addSubview(historyViewer)
            
            // do autolayout
            tableViewConstraints.append(NSLayoutConstraint(item: historyViewer, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
            tableViewConstraints.append(NSLayoutConstraint(item: historyViewer, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
            tableViewConstraints.append(NSLayoutConstraint(item: historyViewer, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
            tableViewConstraints.append(NSLayoutConstraint(item: historyViewer, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
            
            
            NSLayoutConstraint.activateConstraints(tableViewConstraints)


        }
    }
    
    private var tableViewConstraints = [NSLayoutConstraint]()

    // MARK -- Collection View Cell customizing
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}






