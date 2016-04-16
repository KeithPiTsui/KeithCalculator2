//
//  Expression.swift
//  KeithCalculator2
//
//  Created by Pi on 4/11/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import Foundation

/// A struct representing Expression which is inputted by user
struct Expression {
    /// A string that is displayed on Input Display Area
    var displayString: String
    
    /// A string that represents lexial meaning of inputted Expression
    var lexicalString: String
    
    /// A string that represents the result of evaluation of inputted Expression by Calculator
    var resultString: String
    
    /// when this expression is evaluated by Calculator
    var timestamp: NSDate
    
    /// Condition, showing whether this evaluation consider radian or angle on trigonometric function
    var radianStr: String
}