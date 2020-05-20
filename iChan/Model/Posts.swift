//
//  Posts.swift
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
import RealmSwift

class Posts: Object, Codable {
    let posts: [Post]
}

class Post: Codable {
    let no: Int
    let sticky, closed: Int?
    let now, name: String
    let sub: String?
    let com, filename, ext: String?
    let w, h, tnW, tnH: Int?
    let tim, time: Int?
    let md5: String?
    let fsize, resto: Int?
    let capcode: String?
    let semanticURL: String?
    let replies, images, uniqueIPS: Int?

    enum CodingKeys: String, CodingKey {
        case no, sticky, closed, now, name, sub, com, filename, ext, w, h
        case tnW = "tn_w"
        case tnH = "tn_h"
        case tim, time, md5, fsize, resto, capcode
        case semanticURL = "semantic_url"
        case replies, images
        case uniqueIPS = "unique_ips"
    }
}
