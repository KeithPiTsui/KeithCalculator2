//
//  ParsingResult.swift
//  NewKeithCalculator
//
//  Created by Pi on 3/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import Foundation

enum ParsingResult {
    case Value(Double)
    case Formula([Token])
}