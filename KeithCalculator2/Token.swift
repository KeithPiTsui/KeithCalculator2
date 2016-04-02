//
//  Token.swift
//  NewKeithCalculator
//
//  Created by Pi on 3/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import Foundation
/*
#COMPLEXI#
#PRODUCTION#
#PERCENTAGE#
#DELTA#
#PREANSWER#
#DIVISION#
#LEFTPARENTHESIS#
#POWERROOT#
#POWER#
#EXP#               e
#POWER#             ^
#LN#                ln
#LG#                lg
#VARIABLEX#         X
#COMMA#             ,
#RIGHTPARENTHESIS#  (
#MULTIPLICATION#    *
#MINUS#             -
#PLUS#              +
*/


enum Token {
    case IDENTIFIER(String)
    case NUMBER(Double)
    case END
    case COMPLEXI
    case PRODUCTION
    case PERCENTAGE
    case DELTA
    case PREANSWER
    case DIVISION
    case LEFTPARENTHESIS
    case POWERROOT
    case POWER
    case EXP
    case LN
    case LG
    case VARIABLEX
    case VARIABLEY
    case VARIABLEA
    case VARIABLEB
    case VARIABLEC
    case VARIABLED
    case COMMA
    case RIGHTPARENTHESIS
    case MULTIPLICATION
    case MINUS
    case PLUS
    case DOT
    
    private struct Mapping {
        static let tokenTypeRegexMapping: [String:Token] = [
            "^[A-Za-z]+$"       : .IDENTIFIER("id"),
            "^\\d*\\.?\\d*?$"   : .NUMBER(0),
            "^#COMPLEXI#$"      : .COMPLEXI,
            "^#PRODUCTION#$"    : .PRODUCTION,
            "^#PERCENTAGE#$"    : .PERCENTAGE,
            "^#DELTA#$"         : .DELTA,
            "^#PREANSWER#$"     : .PREANSWER,
            "^#DIVISION#$"      : .DIVISION,
            "^#LEFTPARENTHESIS#$" : .LEFTPARENTHESIS,
            "^#POWERROOT#$"     : .POWERROOT,
            "^#POWER#$"         : .POWER,
            "^#EXP#$"           : .EXP,
            "^#LN#$"            : .LN,
            "^#LG#$"            : .LG,
            "^#VARIABLEX#$"     : .VARIABLEX,
            "^#VARIABLEY#$"     : .VARIABLEY,
            "^#VARIABLEA#$"     : .VARIABLEA,
            "^#VARIABLEB#$"     : .VARIABLEB,
            "^#VARIABLEC#$"     : .VARIABLEC,
            "^#VARIABLED#$"     : .VARIABLED,
            "^#COMMA#$"         : .COMMA,
            "^#RIGHTPARENTHESIS#$" : .RIGHTPARENTHESIS,
            "^#MULTIPLICATION#$" : .MULTIPLICATION,
            "^#MINUS#$"         : .MINUS,
            "^#PLUS#$"          : .PLUS,
            "^\\.$"               : .DOT
        ]
    }
    
    static func regconizedSymbol( symbol: String ) -> Token? {
        let range = NSMakeRange(0,symbol.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        for (regexStr,tokenType) in Mapping.tokenTypeRegexMapping {
            guard let regex = try? NSRegularExpression(pattern: regexStr, options: .CaseInsensitive) else { return nil }
            
            let numberOfMatch = regex.numberOfMatchesInString(symbol, options: .Anchored, range: range)
            
            if numberOfMatch == 1{
                switch(tokenType){
                case .NUMBER:
                    if let val = NSNumberFormatter().numberFromString(symbol)?.doubleValue {
                        return .NUMBER(val)
                    }
                case .IDENTIFIER:
                    return .IDENTIFIER(symbol)
                default:
                    return tokenType
                }
            }
        }
        return nil
    }
}

func == (left: Token, right: Token) -> Bool {
    switch (left, right) {
    case
        (.PRODUCTION, .PRODUCTION),
        (.END, .END),
        (.IDENTIFIER, .IDENTIFIER),
        (.NUMBER, .NUMBER),
        (.COMPLEXI, .COMPLEXI),
        (.PERCENTAGE, .PERCENTAGE),
        (.DELTA, .DELTA),
        (.PREANSWER, .PREANSWER),
        (.DIVISION, .DIVISION),
        (.LEFTPARENTHESIS, .LEFTPARENTHESIS),
        (.POWERROOT, .POWERROOT),
        (.POWER, .POWER),
        (.EXP, .EXP),
        (.LN, .LN),
        (.LG, .LG),
        (.VARIABLEX, .VARIABLEX),
        (.VARIABLEY, .VARIABLEY),
        (.VARIABLEA, .VARIABLEA),
        (.VARIABLEB, .VARIABLEB),
        (.VARIABLEC, .VARIABLEC),
        (.VARIABLED, .VARIABLED),
        (.COMMA, .COMMA),
        (.RIGHTPARENTHESIS, .RIGHTPARENTHESIS),
        (.MULTIPLICATION, .MULTIPLICATION),
        (.MINUS, .MINUS),
        (.PLUS, .PLUS): return true
    default: return false
    }
    
}









