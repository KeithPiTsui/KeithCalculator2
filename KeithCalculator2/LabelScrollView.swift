//
//  LabelScrollView.swift
//  KeithCalculator2
//
//  Created by Pi on 4/9/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

class LabelScrollView: UIScrollView {
    
    var text: String = "" {
        didSet {
            label.text = text
        }
    }
    
    weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let lb = UILabel(frame: bounds)
        label = lb
        addSubview(lb)
        contentSize = lb.frame.size
        //lb.addObserver(self, forKeyPath: "text", options: [], context: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if keyPath == "text" {
//            if object === label {
//                let textWidth = label.textWidth()
//                if textWidth > bounds.size.width {
//                    
//                }
//                
//                if label.isTextTruncated() {
//                    var size = label.frame.size
//                    size.width = label.textWidth()
//                    label.frame.size = size
//                    contentSize = label.frame.size
//                    self.setNeedsDisplay()
//                }
//            }
//        }
//    }
    
}
