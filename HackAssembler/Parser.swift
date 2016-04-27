//
//  Parser.swift
//  HackAssembler
//
//  Created by Susan on 2016/04/25.
//  Copyright © 2016年 watanave. All rights reserved.
//

import Foundation

enum CommandType {
    case A_COMMAND
    case C_COMMAND
    case L_COMMAND
}

class Parser {
    
    private var contentStrings: [String] = [String]() 
    private var lineIndex = 0
    
    private var currentCommand: String = ""
    private var currentType: CommandType = .A_COMMAND
    private var currentSymbol: String = ""
    private var currentComp = ""
    private var currentDest = ""
    private var currentJump = ""
    
    init(filePath: String) {
        let string = try? NSString.init(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) 
        
        (string as? String)?.enumerateLines({aLine, _ in
            var str = ""
            let commentRange = aLine.rangeOfString("//")
            if let range = commentRange {
                str = aLine.substringToIndex(range.startIndex)
            }
            else {
                str = aLine
            }

            if str.isEmpty {
                return
            }
            self.contentStrings.append(str)
        })
    }
        
    private func readLine() -> String {
        let currentLine = self.contentStrings[self.lineIndex]
        print(#function, currentLine, self.lineIndex, self.contentStrings.count)
        self.lineIndex += 1
        return currentLine
    }
    
    func reset() {
        self.lineIndex = 0
    }
    
    func hasMoreCommands() -> Bool {
        return self.contentStrings.count > self.lineIndex
    }
    
    func advance() {
        self.currentCommand = self.readLine().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let startIndex = self.currentCommand.startIndex.successor()
        let firstChar = self.currentCommand.substringToIndex(startIndex)
        if firstChar == "@" {
            self.currentSymbol = self.currentCommand.substringFromIndex(startIndex)
            self.currentType = .A_COMMAND
            return
        }
        
        let endIndex = self.currentCommand.endIndex.predecessor()
        let lastChar = self.currentCommand.substringFromIndex(endIndex)
        if firstChar == "(" && lastChar == ")" {
            self.currentSymbol = self.currentCommand.substringWithRange(startIndex...endIndex.predecessor())
            self.currentType = .L_COMMAND
            return
        }
        
        self.currentSymbol = ""
        if self.currentCommand.containsString("=") {
            let components = self.currentCommand.componentsSeparatedByString("=")
            self.currentDest = components.first ?? "" 
            self.currentComp = components.last ?? ""
            self.currentJump = ""
        }
        else if self.currentCommand.containsString(";") {
            let components = self.currentCommand.componentsSeparatedByString(";")
            self.currentDest = ""
            self.currentComp = components.first ?? ""
            self.currentJump = components.last ?? ""
        }
        self.currentType = .C_COMMAND
    }
    
    func commandType() -> CommandType {
        return self.currentType
    }
    
    func symbol() -> String {
        return self.currentSymbol 
    }
    
    func dest() -> String {
        return self.currentDest
    }
    
    func comp() -> String {
        return self.currentComp
    }
    
    func jump() -> String {
        return self.currentJump
    }
}