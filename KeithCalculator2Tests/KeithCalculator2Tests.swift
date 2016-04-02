//
//  KeithCalculator2Tests.swift
//  KeithCalculator2Tests
//
//  Created by Pi on 3/27/16.
//  Copyright © 2016 Keith. All rights reserved.
//

import XCTest
@testable import KeithCalculator2

class KeithCalculator2Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSeflDefiningFunction() {
        
        //        "^[A-Za-z]+$"       : .IDENTIFIER("id"),
        //        "^\\d+\\.?\\d*?$"   : .NUMBER(0),
        //        "^#COMPLEXI#$"      : .COMPLEXI,
        //        "^#PRODUCTION#$"    : .PRODUCTION,
        //        "^#PERCENTAGE#$"    : .PERCENTAGE,
        //        "^#DELTA#$"         : .DELTA,
        //        "^#PREANSWER#$"     : .PREANSWER,
        //        "^#DIVISION#$"      : .DIVISION,
        //        "^#LEFTPARENTHESIS#$" : .LEFTPARENTHESIS,
        //        "^#POWERROOT#$"     : .POWERROOT,
        //        "^#POWER#$"         : .POWER,
        //        "^#EXP#$"           : .EXP,
        //        "^#LN#$"            : .LN,
        //        "^#LG#$"            : .LG,
        //        "^#VARIABLEX#$"     : .VARIABLEX,
        //        "^#COMMA#$"         : .COMMA,
        //        "^#RIGHTPARENTHESIS#$" : .RIGHTPARENTHESIS,
        //        "^#MULTIPLICATION#$" : .MULTIPLICATION,
        //        "^#MINUS#$"         : .MINUS,
        //        "^#PLUS#$"          : .PLUS
        
        
        let myFunctionInput = "CFmyFunction#LEFTPARENTHESIS#10#RIGHTPARENTHESIS#"
        let myFunctionInput2 = "2#PLUS#2"
        let myFunctionInput3 = "CFDPI#LEFTPARENTHESIS#1920#COMMA#1080#COMMA#5.5#RIGHTPARENTHESIS#"
        let myFunctionInput4 = "sum#LEFTPARENTHESIS#sin#LEFTPARENTHESIS##VARIABLEX##RIGHTPARENTHESIS##PLUS#1#COMMA#sum#LEFTPARENTHESIS##VARIABLEX##DIVISION#4#COMMA#1#COMMA#10#RIGHTPARENTHESIS##COMMA#10#RIGHTPARENTHESIS#"
        // replace myFunction Input
        
        let ce = CalculatingEngine()
        
        let result = ce.getResultStringWithLexicalString(myFunctionInput4)
        print(result)
        
    }

    
}
