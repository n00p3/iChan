//
//  Threads4Chan.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//

import Foundation
import Alamofire


struct Thread4Chan: Codable {
    let page: Int
    let threads: [Thread4ChanElement]
}


struct Thread4ChanElement: Codable {
    let no, lastModified, replies: Int

    enum CodingKeys: String, CodingKey {
        case no
        case lastModified = "last_modified"
        case replies
    }
}

typealias Threads4Chan = [Thread4Chan]
