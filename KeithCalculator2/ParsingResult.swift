//
//  ParsingResult.swift
//  NewKeithCalculator
//
//  Created by Pi on 3/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import Foundation

// MARK: - An intermediate result for parser
/// An intermediate result of parser which could be a number or an array of tokens representing expression phase
enum ParsingResult {
    case Value(Double)
    case Formula([Token])
}