//
//  UILabel+Truncation.swift
//  KeithCalculator2
//
//  Created by Pi on 4/9/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

// MARK: - an extension to add features about truncation for a UILabel
extension UILabel {
    //
    func isTextTruncated() -> Bool {
        guard let text = self.text else { return false }
        let size = text.sizeWithAttributes([NSFontAttributeName: self.font])
        return size.width > bounds.width

    }
    
    func textWidth() -> CGFloat {
        guard let text = self.text else { return 0 }
        let size = text.sizeWithAttributes([NSFontAttributeName: self.font])
        return size.width
    }
}
