//
//  CalculatingEngine.swift
//  NewKeithCalculator
//
//  Created by Pi on 3/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import Foundation

// MARK: - a calculating Engine for whole app's need of expression evaluation, using singleton pattern to ensure every call is dispatched to the same calculating Engine.

final class CalculatingEngine {
    
    // MARK: - Singleton implementation
    private init(){}
    let scanner = Scanner()
    let parser = Parser()
    class var universalCalculatingEngine: CalculatingEngine {
        struct SingletonWrapper {
            static let singleton = CalculatingEngine()
        }
        return SingletonWrapper.singleton
    }
    
    private var resultString = ""
    
    /**
     Do calculation according to input lexical string, and then return result back to caller
     - parameter lexicalString: a lexical string represents user input expression for calculating
     - returns: a string that represents the evaluation result of input expression
     */
    func getResultStringWithLexicalString(lexicalString: String) -> String {
        if lexicalString == "" || lexicalString.isEmpty {
            return "No Expression"
        } else {
            if let rs = parser.getResultStringWithTokens(scanner.getTokensWithLexicalString(lexicalString)) {
                return rs
            } else {
                return "Syntax Error"
            }
        }
    }
    
    
}