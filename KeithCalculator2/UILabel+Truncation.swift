//
//  UILabel+Truncation.swift
//  KeithCalculator2
//
//  Created by Pi on 4/9/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

/// an extension to add features about truncation for a UILabel
extension UILabel {
    /// whether label text is wider than label's width
    func isTextTruncated() -> Bool {
        guard let text = self.text else { return false }
        let size = text.sizeWithAttributes([NSFontAttributeName: self.font])
        return size.width > bounds.width

    }
    /// get label text's width
    func textWidth() -> CGFloat {
        guard let text = self.text else { return 0 }
        let size = text.sizeWithAttributes([NSFontAttributeName: self.font])
        return size.width
    }
}
