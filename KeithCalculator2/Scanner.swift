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
            self.scanningTextChanged = true
            self.scanningCharacters = scanningText.characters.map{$0}
            self.tokens = []
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
    private var scanningCharacters = [Character]()
    
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
        if scanningCharacters.count == 0 {
            tokens = [Token]()
            return tokens
        }
        
        var counter = 0
        var charSegment = String(scanningCharacters[counter])
        var orgToken: Token?
        var regconizationState = State.Begin
        while counter < self.scanningCharacters.count {
            
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
                if orgToken == nil { break }
                tokens.append(orgToken!)
                charSegment = String(scanningCharacters[counter])
                orgToken = nil
            } else if regconizationState == .Matched && counter == self.scanningCharacters.count - 1 {
                regconizationState.initializeState()
                if orgToken == nil { break }
                tokens.append(orgToken!)
                break
            }
            else {
                counter += 1
                if counter == scanningCharacters.count { break }
                charSegment.append(scanningCharacters[counter])
            }
            
        }
        tokens.append(Token.END)
        return tokens
    }

}




