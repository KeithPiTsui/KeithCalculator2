//
//  Parser.swift
//  NewKeithCalculator
//
//  Created by Pi on 3/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import Foundation

//    Notes:
//    []  means zero or one
//    use if statement to deal with
//    {}  means zero or more
//    use while statement to deal with
//    |   means or
//    use switch statement to deal with
//    ()  means a unit
//    ''  means a quoted terminal
//    non-captalized means a terminal
//    captalized means a non-terminal or syntactic variable
//
//    Productions:(Started from Expression)
//    FullyExpression = Expression End
//    Expression = ['-'] Term { ( '+' | '-' ) Term }.
//    Term = Term1 | { ( '*' | '/' ) Term1 }.
//    Term1 = Factor | { ( powerroot | power ) Factor | production | percentage }.
//    Factor = number | preanser | '(' Expression ')' | Function | variable .
//    Function = functionIdentifier [ '(' ParameterList ')' ].
//    ParameterList = Expression { ',' | Expression } | Null.
//
//    When to move to next token
//    1 prepared the currentParsingToken for parsing next production
//    for instance, moveToNextParsingToken(); expression()
//    2 each production just using its own element, even use next token for examination, should compensate to last token before return


//    CalCoreToken:
//    case IDENTIFIER
//    case NUMBER
//    case END
//    case COMPLEXI
//    case PRODUCTION
//    case PERCENTAGE
//    case DELTA
//    case PREANSWER
//    case DIVISION
//    case LEFTPARENTHESIS
//    case POWERROOT
//    case POWER
//    case EXP
//    case LN
//    case LG
//    case VARIABLEX
//    case COMMA
//    case RIGHTPARENTHESIS
//    case MULTIPLICATION
//    case MINUS
//    case PLUS





final class Parser {
    
    // MARK: - function mapping
    // TO DO: - call by function
    // FIXME: - add more functions
    /// a mapping storing functions associated with name that calculating with variable or formula which combine variables and expressions
    
    private let formulaAssociatedFunctionMapping = [
        "sum": FunctionUtilities.sumf // a sum function that can calculate a formula with lower and upper limits
    ]
    
    private let normalFunctionMapping =
    [   "sin":FunctionUtilities.sinx,
        "cos":FunctionUtilities.cosx,
        "tan":FunctionUtilities.tanx,
        "asin":FunctionUtilities.arcsinx,
        "acos":FunctionUtilities.arccosx,
        "atan":FunctionUtilities.arctanx,
        "sinh":FunctionUtilities.sinhx,
        "cosh":FunctionUtilities.coshx,
        "tanh":FunctionUtilities.tanhx,
        "asinh":FunctionUtilities.arcsinhx,
        "acosh":FunctionUtilities.arccoshx,
        "atanh":FunctionUtilities.arctanhx,
        "sec":FunctionUtilities.secx,
        "asec":FunctionUtilities.asecx,
        "csc":FunctionUtilities.cscx,
        "acsc":FunctionUtilities.acscx,
        "lg":FunctionUtilities.lg,
        "log":FunctionUtilities.logx,
        "ran":FunctionUtilities.ranx,
        "ln":FunctionUtilities.lnx,
        "Exp":FunctionUtilities.expx,
        "Pi":FunctionUtilities.pix,
        "Pd":FunctionUtilities.productx,
        "e":FunctionUtilities.expx,
        "sum": FunctionUtilities.sum
    ]
    
    // MARK: - storage variable
    /// the parsing token entrance
    var parsingTokens:[Token] = [] {
        didSet {
            if let pt = parsingTokens.last {
                switch pt {
                case .END: break
                default: parsingTokens.append(Token.END)
                }
            }
            orgTokens = parsingTokens;
            parsingTokensChanged = true;
            currentParsingTokenOffset = 0
        }
    }
    
    // restrict the range of parsing tokens
    private var currentParsingTokenOffset: Int = 0 {
        didSet {
            currentParsingTokenOffset = min( max( currentParsingTokenOffset, 0 ), orgTokens.count - 1 )
        }
    }
    
    private var lastResult: ParsingResult?            // record the last result for usage of pre-answer
    private var parsingTokensChanged:Bool = true    // record whethe the original tokens is changed or not
    private var resultValue: ParsingResult?           // for storage of current result of tokens parsing
    private var orgTokens:[Token] = []       // for storage of original tokens for parsing next time
    
    // MARK: - computed variable
    /// a string representing the parsing result
    var result:String? {
        if let v = valueOfResult { return v.description } else { return nil }
    }
    
    /// a number representing the parsing result
    var valueOfResult: Double? {
        if parsingTokensChanged {
            lastResult = resultValue
            resultValue = getResult()
            parsingTokensChanged = false
        }
        if resultValue != nil {
            switch resultValue! {
            case .Value(let x): return x
            case .Formula( _): return nil
            }
        } else { return nil }
    }
    
    /// a formula representing the parsing result
    var formulaOfResult: [Token]? {
        if parsingTokensChanged {
            lastResult = resultValue
            resultValue = getResult()
            parsingTokensChanged = false
        }
        if resultValue != nil {
            switch resultValue! {
            case .Value(_): return nil
            case .Formula(let f): return f
            }
        } else { return nil }
    }
    
    
    private var lastParsingToken: Token {
        if currentParsingTokenOffset == 0 { return orgTokens[currentParsingTokenOffset] } else {
            return orgTokens[currentParsingTokenOffset - 1]
        }
    }
    
    private var currentParsingToken: Token {
        return orgTokens[currentParsingTokenOffset]
    }
    
    private var nextParsingToken: Token {
        return orgTokens[currentParsingTokenOffset + 1]
    }
    
    private func moveToNextParsingToken() -> Bool {
        if currentParsingTokenOffset <= orgTokens.count - 1 {
            currentParsingTokenOffset += 1
            return true
        } else { return false }
    }
    
    private func moveToLastParsingToken() -> Bool{
        if currentParsingTokenOffset > 0 {
            currentParsingTokenOffset -= 1
            return true
        } else { return false }
    }
    
    private func getResult() -> ParsingResult? {
        
        if orgTokens.count == 0 { return nil }
        
        switch currentParsingToken {
        case .END: return nil
        default: return fullyExpression()
        }
    }
    
    // MARK: - initializer
    
    init(){}
    
    init(tokenArray:[Token]){ parsingTokens = tokenArray }
    
    
    
    
    
    /*
    Notes:
    []  means zero or one
    use if statement to deal with
    {}  means zero or more
    use while statement to deal with
    |   means or
    use switch statement to deal with
    ()  means a unit
    ''  means a quoted terminal
    non-captalized means a  terminal
    captalized means a non-terminal or syntactic variable
    
    Productions:(Started from Expression)
    FullyExpression = Expression End
    Expression = ['-'] Term { ( '+' | '-' ) Term }.
    Term = Term1 | { ( '*' | '/' ) Term1 }.
    Term1 = Factor | { ( powerroot | power ) Factor | production | percentage }.
    Factor = number | preanser | '(' Expression ')' | Function | variable .
    Function = functionIdentifier [ '(' ParameterList ')' ].
    ParameterList = Expression { ',' | Expression } | Null.
    
    When to move to next token
    1 prepared the currentParsingToken for parsing next production
    for instance, moveToNextParsingToken(); expression()
    2 each production just using its own element, even use next token for examination, should compensate to last token before return
    */
    
    
    // MARK: - production function
    private func fullyExpression() -> ParsingResult? {
        
        
        if currentParsingToken == .END {
            return nil
        }
        
        let v = expression()
        
        moveToNextParsingToken() // should be End
        if currentParsingToken == .END { return v } else { return nil }
        
    }
    
    private func expression() -> ParsingResult?{
        // Expression = ['-'] Term { ( '+' | '-' ) Term }.
        
        var val: Double? // for storage a result of value
        //var returnIsValue = false // a sign for this method returning a formular
        var parserResultFormula = [Token]() // for storage a result of fomula
        
        var isPrefixWithMinus = false
        if currentParsingToken == .MINUS {
            parserResultFormula.append(currentParsingToken) // append a prefix minus sign
            isPrefixWithMinus = true;
            moveToNextParsingToken() // should be an element of term
        } else { false }
        
        if let v = term() {
            switch v {
            case .Value(let x):
                parserResultFormula.append(Token.NUMBER(x)) // append a term of value
                if isPrefixWithMinus { val = -x } else { val = x } // do calculation
            case .Formula(let ts): val = nil;  parserResultFormula.appendContentsOf(ts) // append a term of formula
            }
        } else { return nil }
        
        
        moveToNextParsingToken() // should be plus sign or minus sign or end
        while currentParsingToken == .PLUS || currentParsingToken == .MINUS {
            
            let thisToken = currentParsingToken
            
            parserResultFormula.append(currentParsingToken) // append a plus sign or minus sign
            
            moveToNextParsingToken() // currentParsingToken should be the second term in Expression Production
            
            if currentParsingToken == .END { return nil } else {
                if let v = term() {
                    switch v {
                    case .Value(let x):
                        parserResultFormula.append(Token.NUMBER(x)) // append a term of value
                        if val != nil { // do calculation of this while token
                            switch thisToken {
                            case .PLUS: val! += x
                            case .MINUS: val! -= x
                            default: break
                            }
                        }
                    case .Formula(let ts): val = nil; parserResultFormula.appendContentsOf(ts) // append a next term to fomula
                    }
                } else { return nil }
            }
            
            moveToNextParsingToken() //should be plus sign or minus sign or end
        }
        
        moveToLastParsingToken() // compensate for last moveToNext operation which is for examination
        
        return val != nil ? ParsingResult.Value(val!) : ParsingResult.Formula(parserResultFormula)
    }
    
    private func term() -> ParsingResult?{
        //Term = Term1 | { ( '*' | '/' ) Term1 }.
        
        var val: Double? // for storage a result of value
        // _ = false // a sign for this method returning a formular
        var parserResultFormula = [Token]() // for storage a result of fomula
        
        if let v = self.term1() {
            switch v {
            case .Value(let x): val = x; parserResultFormula.append(Token.NUMBER(x)) // append a term1 of value
            case .Formula(let ts): val = nil;  parserResultFormula.appendContentsOf(ts) // append a term1 of formula
            }
        } else { return nil }
        
        moveToNextParsingToken() // should be a multiplication sign or division sign
        
        while currentParsingToken == .MULTIPLICATION || currentParsingToken == .DIVISION {
            
            let thisToken = currentParsingToken
            
            
            parserResultFormula.append(currentParsingToken) // append a multiplication sign or division sign
            
            moveToNextParsingToken() // should be an elements of term1
            if currentParsingToken == .END { return nil } else {
                if let v = term1() {
                    switch v {
                    case .Value(let x):
                        parserResultFormula.append(Token.NUMBER(x)) // append a second term1
                        if val != nil {
                            switch thisToken {
                            case .MULTIPLICATION: val! *= x
                            case .DIVISION: val! /= x
                            default: break
                            }
                        }
                    case .Formula(let ts): val = nil;  parserResultFormula.appendContentsOf(ts) // append a second term1
                    }
                } else { return nil }
            }
            
            moveToNextParsingToken() // shoud be a multiplication sign or division sign
        }
        
        moveToLastParsingToken() // compensate for last moveToNext operation which is for examination
        
        return val != nil ? ParsingResult.Value(val!) : ParsingResult.Formula(parserResultFormula)
    }
    
    private func term1() -> ParsingResult?{
        //Term1 = Factor | { ( powerroot | power ) Factor | production | percentage }.
        
        var val: Double? // for storage a result of value
        //var returnIsValu_gn // for this method returning a formular
        var parserResultFormula = [Token]() // for storage a result of fomula
        
        if let v = self.factor() {
            switch v {
            case .Value(let x): val = x; parserResultFormula.append(Token.NUMBER(x)) // append a factor of value
            case .Formula(let ts): val = nil;  parserResultFormula.appendContentsOf(ts) // append a factor of formula
            }
        } else { return nil }
        
        moveToNextParsingToken() // should be a powerroot or power or production or percentage sign
        
        while currentParsingToken == .POWERROOT || currentParsingToken == .POWER
            || currentParsingToken == .PRODUCTION || currentParsingToken == .PERCENTAGE {
                
                let thisToken = currentParsingToken
                
                parserResultFormula.append(currentParsingToken) // append powerroot or power or production or percentage
                
                if currentParsingToken == .POWERROOT || currentParsingToken == .POWER {
                    moveToNextParsingToken() // should be a factor
                    if currentParsingToken == .END { return nil } else {
                        if let v = factor() {
                            switch v { // do calculation if factor is value
                            case .Value(let x):
                                parserResultFormula.append(Token.NUMBER(x)) // append the second factor of value
                                if val != nil {
                                    switch thisToken {
                                    case .POWERROOT: val! = pow(x,1/val!)
                                    case .POWER: val! = pow(val!, x)
                                    default: break
                                    }
                                }
                            case .Formula(let ts): val = nil;  parserResultFormula.appendContentsOf(ts) // append the factor of formula
                            }
                        } else { return nil }
                    }
                }
                
                
                if currentParsingToken == .PRODUCTION {
                    if val != nil { if let v = FunctionUtilities.productx([val!]) { val = v } else { return nil} }
                }
                
                if currentParsingToken == .PERCENTAGE { val = val != nil ? val! / 100 : nil }
                
                moveToNextParsingToken()
        }
        
        moveToLastParsingToken()
        
        return val != nil ? ParsingResult.Value(val!) : ParsingResult.Formula(parserResultFormula)
    }
    
    private func factor() -> ParsingResult?{
        //Factor = number | preanser | '(' Expression ')' | Function | variable .
        
        var val: Double? // for storage a result of value
        //var returnIsValu_gn for this method returning a formular
        var parserResultFormula = [Token]() // for storage a result of fomula
        
        switch currentParsingToken {
        case .VARIABLEX:
            return ParsingResult.Formula([currentParsingToken])
        case .NUMBER(let v):
            return ParsingResult.Value(v)
        case .PREANSWER:
            return lastResult
        case .IDENTIFIER:
            if let v = functionProduction() {
                switch v {
                case .Value(let x):
                    parserResultFormula.append(Token.NUMBER(x)) // append an formula of expression
                    val = x // do calculation if factor is value
                case .Formula(let ts):
                    val = nil; parserResultFormula.appendContentsOf(ts)
                }
                return val != nil ? ParsingResult.Value(val!) : ParsingResult.Formula(parserResultFormula)
            } else { return nil }
        case .LEFTPARENTHESIS:
            
            parserResultFormula.append(currentParsingToken) // append left parenthesis
            
            moveToNextParsingToken() // should be an element of expression
            
            if currentParsingToken == .END { return nil }
            
            if let v = self.expression() {
                switch v {
                case .Value(let x):
                    parserResultFormula.append(Token.NUMBER(x)) // append an formula of expression
                    val = x // do calculation if factor is value
                case .Formula(let ts): val = nil;  parserResultFormula.appendContentsOf(ts) // append a factor of formula
                }
            } else { return nil }
            
            moveToNextParsingToken() // should be right parenthesis
            
            if currentParsingToken == .END { return nil }
            
            if currentParsingToken == .RIGHTPARENTHESIS {
                parserResultFormula.append(currentParsingToken) // append a right parenthesis into formula
                return val != nil ? ParsingResult.Value(val!) : ParsingResult.Formula(parserResultFormula)
            } else { return nil }
            
        default: return nil
        }
    }
    
    private func functionProduction() -> ParsingResult?{
        //Function = functionIdentifier [ '(' ParameterList ')' ].
        // return a formula representing this function if parameter list in this function contains a variable
        // or a value of this function
        
        //var val: Double?_ storage a result of value
        //var re_se // a sign for this method returning a formular
        var parserResultFormula = [Token]() // for storage a result of fomula
        
        if case Token.IDENTIFIER(let funcName) = currentParsingToken {
        
//        if  currentParsingToken == Token.IDENTIFIER("") {
            
            parserResultFormula.append(currentParsingToken)
            
//            let funcName = currentParsingToken.value as? String
//            if funcName == nil { return nil }
            
            moveToNextParsingToken()
            
            if (currentParsingToken == Token.LEFTPARENTHESIS) == false {
                moveToLastParsingToken()
                if let v = callFunctionWith(funcName, andParameters: nil) {
                    return ParsingResult.Value(v)
                } else { return nil }
                
            } else {
                parserResultFormula.append(currentParsingToken);
                
                moveToNextParsingToken() // should be an element of paralist
                
                let (ps, pr) = paraList()
                
                if ps == nil || pr == nil { return nil }
                if pr != nil {
                    switch pr! {
                    case .Value(_): break
                    case .Formula(let ts): parserResultFormula.appendContentsOf(ts)
                    }
                }
                
                moveToNextParsingToken() // should be right parenthesis
                
                if currentParsingToken == .RIGHTPARENTHESIS {
                    parserResultFormula.append(currentParsingToken);
                    // if function type is not for formula and  parameter list contains formula
                    // then return a formula representing this function
                    // else return the result of this function after call this function
                    
                    let functionForFormula = formulaAssociatedFunctionMapping[funcName] != nil
                    let functionForNormal = normalFunctionMapping[funcName] != nil
                    var paraListContainsFormula = false
                    
                    for i in 0 ..< ps!.count {
                        switch ps![i] {
                        case .Formula(_): paraListContainsFormula = true
                        case .Value(_): break
                        }
                    }
                    
                    
                    
                    if functionForFormula && paraListContainsFormula { // formula function with formula
                        if let v = callFunctionWith(funcName, andParameters: ps ) {
                            return ParsingResult.Value(v)
                        } else { return nil }
                    } else if functionForNormal && !paraListContainsFormula { // normal function with normal parameters
                        if let v = callFunctionWith(funcName, andParameters: ps ) {
                            return ParsingResult.Value(v)
                        } else { return nil }
                    } else if funcName.hasPrefix("CF") && !paraListContainsFormula { // customized function with normal parameter
                        if let v = callFunctionWith(funcName, andParameters: ps ) {
                            return ParsingResult.Value(v)
                        } else { return nil }
                    } else {
                        return ParsingResult.Formula(parserResultFormula)
                    }
                    
                } else { moveToLastParsingToken(); return nil }
            }
            
        } else { return nil }
    }
    
    private func paraList() -> ([ParsingResult]?, ParsingResult? ) {
        //ParameterList = Expression { ',' | Expression } | Null.
        // return a parameter list whose elements are all not  variable and ParserResult is nil
        // and return a formula in ParserResult
        
        var paras = [ParsingResult]()
        var parserResultFormula = [Token]() // for storage a result of fomula

        
        if currentParsingToken == .RIGHTPARENTHESIS {      // null
            moveToLastParsingToken() // compensate
        } else {        // Expression { ',' | Expression }
            if let v = self.expression() {
                paras.append(v)
                switch v {
                case .Formula(let ts): parserResultFormula.appendContentsOf(ts)
                case .Value(let x): parserResultFormula.append(Token.NUMBER(x))
                }
            } else { return (nil,nil) } // expression
            
            
            moveToNextParsingToken() // should be a comma
            
            while currentParsingToken == .COMMA {
                parserResultFormula.append(currentParsingToken)
                
                moveToNextParsingToken()
                if let v = self.expression() {
                    paras.append(v)
                    switch v {
                    case .Formula(let ts): parserResultFormula.appendContentsOf(ts)
                    case .Value(let x): parserResultFormula.append(Token.NUMBER(x))
                    }
                } else { return (nil,nil) }
                moveToNextParsingToken()
            }
            moveToLastParsingToken()
        }
        
        return (paras, ParsingResult.Formula(parserResultFormula))
        
    }
    
    // MARK: - function calling agent
    private func callFormulaAssociatedFunctionWith( functionName: String, andParameters ps: [ParsingResult] ) -> Double? {
        if let functionPointer = formulaAssociatedFunctionMapping[functionName] {
            return functionPointer( ps )
        } else { return nil }
    }
    
    private func callNormualFunctionWith( functionName: String, andParameters ps: [Double] ) -> Double? {
        
        if let functionPointer = normalFunctionMapping[functionName] {
            return functionPointer( ps )
        } else { return FunctionUtilities.customFunction(functionName, paras:ps ) }
        
    }
    
    
    private func callFunctionWith(functionName:String, andParameters ps:[ParsingResult]?) -> Double?{
        if ps == nil { return callNormualFunctionWith(functionName, andParameters: [Double]()) } else {
            var formulaAssociated = false
            var doubles = [Double]()
            for i in 0..<ps!.count {
                switch ps![i] {
                case .Formula(_): formulaAssociated = true
                case .Value(let x): doubles.append(x)
                }
            }
            if formulaAssociated { return callFormulaAssociatedFunctionWith(functionName, andParameters: ps!) } else {
                return callNormualFunctionWith(functionName, andParameters: doubles)
            }
        }
    }
}











