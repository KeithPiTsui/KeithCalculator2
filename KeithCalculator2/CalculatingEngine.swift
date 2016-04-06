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
    
    private init(){}
    
    class var universalCalculatingEngine: CalculatingEngine {
        struct SingletonWrapper {
            static let singleton = CalculatingEngine()
        }
        return SingletonWrapper.singleton
    }
    
    private var inputLexicalString = ""
    
    private var resultString = ""
    
    
    func getResultStringWithLexicalString(lexicalString: String) -> String {
        
        if lexicalString == "" || lexicalString.isEmpty {
            inputLexicalString = lexicalString
            resultString = ""
            return resultString
        } else {
            inputLexicalString = lexicalString
            let scanner = Scanner.universalCalculatorScanner
            let parser = Parser.universalCalculatorParser
            if let rs = parser.getResultStringWithTokens(scanner.getTokensWithLexicalString(inputLexicalString)) {
                resultString = rs
            } else {
                resultString = "Syntax Error"
            }
            return resultString
        }
        
    }
    
    
}