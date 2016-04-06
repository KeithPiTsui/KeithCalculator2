//
//  File.swift
//  KeithCalculator2
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import UIKit

//typealias Key = (displayString: String, lexicalString: String, keypadString: String, positionInOrder: Int)

struct Key {
    var displayString: String
    var lexicalString: String
    var keypadString: String
    var positionInOrder: Int = 0
    var preferColor: UIColor?
    var preferFont: UIFont?
    
    init?(keySource: [String: AnyObject]) {
        let colorRange: CGFloat = 255
        guard let displayString = keySource["displayString"] as? String else { return nil }
        guard let lexicalString = keySource["lexicalString"] as? String else { return nil }
        guard let keypadString = keySource["keypadString"] as? String else { return nil }
        guard let positionInOrder = keySource["positionInOrder"] as? Int else { return nil }
        
        
        if let colorElements: [CGFloat] = keySource["colorRGBA"] as? [CGFloat] {
            if colorElements.count == 3 {
                self.preferColor = UIColor(red: colorElements[0]/colorRange, green: colorElements[1]/colorRange, blue: colorElements[2]/colorRange, alpha: 1)
            } else if colorElements.count == 4 {
                self.preferColor = UIColor(red: colorElements[0]/colorRange, green: colorElements[1]/colorRange, blue: colorElements[2]/colorRange, alpha: colorElements[3])
            }
        }
        
        
        let fontName = keySource["fontName"] as? String ?? "AmericanTypewriter"
        let fontSize = keySource["fontSize"] as? CGFloat ?? 17
        self.preferFont = UIFont(name: fontName, size: fontSize)
    
        
        self.displayString = displayString
        self.lexicalString = lexicalString
        self.positionInOrder = positionInOrder
        self.keypadString = keypadString
        
    }
}