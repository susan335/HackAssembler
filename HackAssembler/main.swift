//
//  main.swift
//  HackAssembler
//
//  Created by Susan on 2016/04/25.
//  Copyright © 2016年 watanave. All rights reserved.
//

import Foundation

let arguments = NSProcessInfo.processInfo().arguments
let filePath = arguments[1] ?? ""
print (filePath)
let parser = Parser.init(filePath: filePath)

NSFileManager.defaultManager().createFileAtPath(arguments[2], contents: nil, attributes: nil)
let fileHandle = NSFileHandle.init(forWritingAtPath: arguments[2])



let symbolTable = SymbolTable()
var variableSymbolAdress: UInt16 = 0x0010
var instructionAddress: UInt16 = 0x0000
while parser.hasMoreCommands() {
    parser.advance()
    
    switch parser.commandType() {
    case .A_COMMAND:
        instructionAddress += 1
    case .C_COMMAND:
        instructionAddress += 1
    case .L_COMMAND:
        symbolTable.addEntry(parser.symbol(), address: instructionAddress)
    }
}

parser.reset()
var bin = ""

while parser.hasMoreCommands() {
    parser.advance()
    
    var aCommand: UInt16 = 0
    switch parser.commandType() {
    case .A_COMMAND:
        if let symbol = UInt16.init(parser.symbol()) {
            aCommand = symbol
        }
        else if let address = symbolTable.getAddress(parser.symbol()) {
            aCommand = address
        }
        else {
            aCommand = variableSymbolAdress
            symbolTable.addEntry(parser.symbol(), address: variableSymbolAdress)
            variableSymbolAdress += 1
        }
    case .C_COMMAND:
        aCommand = 0b1110_0000_0000_0000
        aCommand += Code.comp(parser.comp()) << 6
        aCommand += Code.dest(parser.dest()) << 3
        aCommand += Code.jump(parser.jump())
    case .L_COMMAND: continue
    }
    
    var aLine = String(aCommand, radix: 2) + "\n"
    while aLine.characters.count <= 16 {
        aLine.insert("0", atIndex: aLine.startIndex)
    }
//    print(aLine)
    bin += aLine
}

let writeData = bin.dataUsingEncoding(NSUTF8StringEncoding)!
fileHandle?.writeData(writeData)

fileHandle?.closeFile()

