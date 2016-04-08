//
//  FeatureKeyBackgroundView.swift
//  KeithCalculator2
//
//  Created by Pi on 4/8/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

class FeatureKeyBackgroundView: UIView {

    override func drawRect(rect: CGRect) {
        let con = UIGraphicsGetCurrentContext()!
        CGContextAddEllipseInRect(con, CGRect(x: 0, y: 0, width: 3, height: 3))
        CGContextSetFillColorWithColor(con, UIColor.grayColor().CGColor)
        CGContextFillPath(con)

    }

}
