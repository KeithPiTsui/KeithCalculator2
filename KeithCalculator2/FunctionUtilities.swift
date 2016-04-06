//
//  FunctionUtilities.swift
//  KeithCalculator
//
//  Created by Pi on 8/13/15.
//  Copyright (c) 2015 Keith. All rights reserved.
//

import Foundation

final class FunctionUtilities {
    //sum#LEFTPARENTHESIS##VARIABLEX##COMMA#1#COMMA#9#RIGHTPARENTHESIS#
    static var customizedFunction = [
        "CFDPI":
        [Token.NUMBER(2),Token.POWERROOT,Token.LEFTPARENTHESIS, Token.VARIABLEA, Token.POWER, Token.NUMBER(2), Token.PLUS, Token.VARIABLEB, Token.POWER, Token.NUMBER(2), Token.RIGHTPARENTHESIS, Token.DIVISION, Token.VARIABLEC]
    ]
    
    static func setCustomFunction(name: String, withDefinitionTokens definitionTokens: [Token]) {
        if name.isEmpty || name == "" || definitionTokens.isEmpty { return }
        let cfName = "CF" + name
        self.customizedFunction[cfName] = definitionTokens
    }
    
    static func customFunction(name: String, paras: [Double]) -> Double? {
        
        guard var functionDefinition = customizedFunction[name] else { return nil }
        // replacing the variable by parameter of paras
        
        // Customised function variables replacement
        
        let variableTokens = [Token.VARIABLEA,Token.VARIABLEB, Token.VARIABLEC, Token.VARIABLED]
        
        for i in 0 ..< variableTokens.count {
            if paras.count > i {
                functionDefinition = functionDefinition.map{ $0 == variableTokens[i] ? Token.NUMBER(paras[i]) : $0 }
            }
        }
        
        return Parser.universalCalculatorParser.getResultValueWithTokens(functionDefinition)
    }
    
    
    
    static func sumf( paras: [ParsingResult] ) -> Double? {
        
        if paras.count != 3 { return nil }
        
        let formulaParserResult = paras[0]
        let lowerLimitParserResult = paras[1]
        let upperLimitParserResult = paras[2]
        
        var formula = [Token]()
        var lowerLimit: Int
        var upperLimit: Int
        
        switch formulaParserResult {
        case .Formula(let f): formula = f
        case .Value(_): return nil
        }
        
        switch lowerLimitParserResult {
        case .Formula(_): return nil
        case .Value(let x): lowerLimit = Int(x)
        }
        
        switch upperLimitParserResult {
        case .Formula(_): return nil
        case .Value(let x): upperLimit = Int(x)
        }
        
        if lowerLimit > upperLimit { swap(&lowerLimit, &upperLimit) }
        
        var total: Double = 0
        let parser = Parser.universalCalculatorParser
        for i in lowerLimit ... upperLimit {
            let elementForReplace = Token.NUMBER(Double(i))
            guard let v = parser.getResultValueWithTokens(formula.map{ $0 == .VARIABLEX ? elementForReplace : $0 })  else { return nil }
            total += v
        }
        
        return total
        
    }
    
    static func sum( paras: [Double] ) -> Double? {
        return paras.count == 3 ?
            paras[0] * abs(paras[1] - paras[2])
            : nil
    }
    
    static  func sinx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
                sin(paras[0])
                : nil
    }
    
    static  func cosx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            cos(paras[0])
            : nil
    }
    
    static  func tanx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            tan(paras[0])
            : nil
    }
    
    static  func arcsinx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            asin(paras[0])
            : nil
    }
    
    static  func arccosx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            acos(paras[0])
            : nil
    }
    
    static  func arctanx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            atan(paras[0])
            : nil
    }
    
    static  func secx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            1 / cos(paras[0])
            : nil
    }
    
    static  func asecx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            acos(1/paras[0])
            : nil
    }
    
    static  func cscx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            1 / sin(paras[0])
            : nil
    }
    
    static  func acscx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            asin(1/paras[0])
            : nil
    }
    
    static  func sinhx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            sinh(paras[0] / 180 * M_PI)
            : nil
    }
    
    static  func coshx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            cosh(paras[0] / 180 * M_PI)
            : nil
    }
    
    static  func tanhx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            tanh(paras[0] / 180 * M_PI)
            : nil
    }
    
    static  func arcsinhx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            asinh(paras[0]) / M_PI * 180
            : nil
    }
    
    static  func arccoshx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            acosh(paras[0]) / M_PI * 180
            : nil
    }
    
    static  func arctanhx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            atanh(paras[0]) / M_PI * 180
            : nil
    }
    
    static  func productx(paras:[Double]) -> Double? {
        if paras.count != 1 {
            return nil
        } else {
            if paras[0] < 2 {
                return ceil(paras[0])
            } else {
                var v = 1.0
                for i in 2...Int(paras[0]) {
                    v *= Double(i)
                }
                return v
            }
        }
    }
    
    static  func crnx(paras:[Double]) -> Double? {
        return paras.count == 2 ?
            productx(paras)!/productx(paras)!
            : nil
    }
    
    static  func pnx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            productx(paras)
            : nil
    }
    
    static  func logx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            productx(paras)
            : nil
    }
    
    static  func lg(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            log10(paras[0])
            : nil
    }
    
    static  func lnx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            log(paras[0]) / log (exp(1))
            : nil
    }
    
    static  func expx(paras:[Double]) -> Double? {
        return exp(1.0)
    }
    
    static  func ranx(paras:[Double]) -> Double? {
        var r:Int = random()
        if paras.count == 2 {
            let v0 = Int(paras[0])
            let v1 = Int(paras[1])
            let range = abs( v1 - v0 + 1  )
            r = r % range + min(v0, v1)
        } else {
            r = r % 10
        }
        return Double(r)
    }
    
    static  func ranxx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            productx(paras)
            : nil
    }
    
    static  func modx(paras:[Double]) -> Double? {
        return paras.count == 1 ?
            productx(paras)
            : nil
    }
    
    static  func pix(paras:[Double]) -> Double? {
        return M_PI
    }
    
}