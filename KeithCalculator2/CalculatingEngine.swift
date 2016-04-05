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
    private let scanner = Scanner()
    private let parser = Parser()
    
    private var inputLexicalString = ""
    
    private var resultString = ""
    
    
    func getResultStringWithLexicalString(lexicalString: String) -> String {
        
        if lexicalString == "" || lexicalString.isEmpty {
            inputLexicalString = lexicalString
            resultString = ""
            return resultString
        } else {
            inputLexicalString = lexicalString
            scanner.scanningText = inputLexicalString
            parser.parsingTokens = scanner.tokenStream
            if let rs = parser.result { resultString = rs } else {
                resultString = "Syntax Error"
            }
            return resultString
        }
        
    }
    
    
}