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
     Contents of what to display on a history list
     */
    var historyRecords: [(displayString: String, lexicalString: String, result: String)] = [(displayString: String, lexicalString: String, result: String)]() {
        didSet{
            historyViewer.reloadData()
        }
    }
    
    /**
     a table view as a list for displaying historical input expression
     */
    weak var historyViewer: UITableView!
    
    /**
     a constant which marks a reusable cell in list (table view)
     */
    let reusableIdentifier = "reusable cell"
    
    // MARK -- Collection View Cell customizing
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 3
        let viewer = UITableView()
        contentView.addSubview(viewer)
        historyViewer = viewer
        viewer.dataSource = self
        viewer.delegate = self
        viewer.registerClass(UITableViewCell.self, forCellReuseIdentifier: reusableIdentifier)
        viewer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraint(NSLayoutConstraint(item: viewer, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: viewer, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: viewer, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: viewer, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

// MARK: - historical list data source protocol
extension HistoryRecordCollectionViewCell: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyRecords.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableIdentifier, forIndexPath: indexPath)
        let record = historyRecords[indexPath.row]
        cell.textLabel?.text = " \(record.displayString) = \(record.result)"
        cell.textLabel?.textColor = UIColor.redColor()
        return cell
    }
}
// MARK: - historical list delegate protocol
extension HistoryRecordCollectionViewCell: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
    }
}






