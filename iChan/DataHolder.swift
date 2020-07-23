//
//  DataHolder.swift
//  iChan
//
//  Created by Mateusz Głowski on 23/07/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation

struct DataHolder {
    static var shared = DataHolder()
    
    var threadNo = 0
    var threadBoard = ""
    
    init() {
        
    }
}
