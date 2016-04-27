//
//  SymbolTable.swift
//  HackAssembler
//
//  Created by Susan on 2016/04/27.
//  Copyright © 2016年 watanave. All rights reserved.
//

import Foundation

class SymbolTable {
    
    private var table = [(symbol: String, address: UInt16)]()
    
    init() {
        self.table.append(("SP",    0x0000))
        self.table.append(("LCL",   0x0001))
        self.table.append(("ARG",   0x0002))
        self.table.append(("THIS",  0x0003))
        self.table.append(("THAT",  0x0004))
        self.table.append(("SCREEN",0x4000))
        self.table.append(("KBD",   0x6000))
        for idx in 0...15 {
            let symbol = "R" + String(idx, radix: 10) 
            self.table.append((symbol,  UInt16(idx)))
        }
    }
            
    func addEntry(symbol: String, address: UInt16) {
        self.table.append((symbol, address))
    }
    
    func contains(symbol: String) -> Bool {
        return self.table.contains { cmpSym, _ -> Bool in
            return symbol == cmpSym
        }
    }
    
    func getAddress(symbol: String) -> UInt16? {
        return self.table.filter({cmpSym, _ in
            return symbol == cmpSym
        })
        .first?
        .address
    }
}