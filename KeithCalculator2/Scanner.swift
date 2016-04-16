//
//  Scanner.swift
//  NewKeithCalculator
//
//  Created by Pi on 3/3/16.
//  Copyright © 2016 Keith. All rights reserved.
//

// A scanner is used to accept input character string or a sequence of characters, 
// and then recognize the symbols within input character stream, 
// thus generate a sequence of tokens for further processing in a Parser.

// Using the regular expression for regconizing the symbol in an input character stream.


import Foundation

final class Scanner {
    
    private var scanningText = "" {
        didSet{
            self.scanningTextChanged = oldValue != scanningText
        }
    }
    
    private var tokenStream:[Token] {
        if scanningTextChanged {
            self.generateTokens()
            scanningTextChanged = false
        }
        return tokens
    }
    
    private var scanningTextChanged = true
    private var tokens = [Token]()
    
    // using a state machine to control state tranfers caused by action.
    private enum State {
        case Begin      // symbol regconization start
        case Matched    // symbol regconization intermediate stage
        case End        // symbol regconization done
        
        mutating func stateTransferredByAction(matched matched: Bool = true) {
            switch self {
            case .Begin:
                    if matched { self = .Matched }
            case .Matched:
                    if !matched { self = .End }
            case .End:
                    self = .Begin
            }
        }
        
        mutating func initializeState() {
            self = .Begin
        }
        
    }
    
    /**
     Get token array by inputing a lexical string for scanner to do lexial analysis
     - parameter str: a lexical string
     - returns: return an array of Token which could be parsing by parser for semantic analysis
     */
    
    func getTokensWithLexicalString(str: String) -> [Token] {
        self.scanningText = str
        return self.tokenStream
    }
    
    //read each charater from characters, then match those with regex to get a token, via algorithm of finite state machine
    private func generateTokens() -> [Token]{
        self.tokens = []
        guard !scanningText.isEmpty && scanningText != "" else { return tokens }
        
        var counter = scanningText.startIndex
        var charSegment = String(scanningText[counter])
        var orgToken: Token?
        var regconizationState = State.Begin
        while counter < self.scanningText.endIndex {
            
            // each matching will cause a state transfer
            if let t = Token.regconizedSymbol(charSegment) {
                regconizationState.stateTransferredByAction(matched: true)
                orgToken = t
            } else {
                regconizationState.stateTransferredByAction(matched: false)
            }
            
            // according to the condition where the longest token regconized can be take into result
            // after the longest token regconized, start to regconize a new symbol, so initialize the regconization state.
            if regconizationState == .End  {
                regconizationState.initializeState()
                guard orgToken != nil else { break }
                tokens.append(orgToken!)
                charSegment = String(scanningText[counter])
                orgToken = nil
            } else if regconizationState == .Matched && counter == self.scanningText.endIndex.predecessor() {
                regconizationState.initializeState()
                guard orgToken != nil else { break }
                tokens.append(orgToken!)
                break
            }
            else {
                counter = counter.successor()
                guard counter < scanningText.endIndex else { break }
                charSegment.append(scanningText[counter])
            }
        }
        tokens.append(Token.END)
        return tokens
    }

}




