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
    let now: String
    let name: String?
    let sub: String?
    var com, filename, ext: String?
    let w, h, tnW, tnH: Int?
    var tim, time: Int?
    let md5: String?
    let fsize, resto: Int?
    let capcode: String?
    let semanticURL: String?
    let replies, images, uniqueIPS: Int?
    let country: String?
    let countryName: String?

    enum CodingKeys: String, CodingKey {
        case no, sticky, closed, now, name, sub, com, filename, ext, w, h, country
        case tnW = "tn_w"
        case tnH = "tn_h"
        case tim, time, md5, fsize, resto, capcode
        case semanticURL = "semantic_url"
        case replies, images
        case uniqueIPS = "unique_ips"
        case countryName = "country_name"
    }
    
    init() {
        no = 0
        sticky = nil
        closed = nil
        now = ""
        name = nil
        sub = nil
        com = nil
        filename = nil
        ext = nil
        w = nil
        h = nil
        tnW = nil
        tnH = nil
        tim = nil
        time = nil
        md5 = nil
        fsize = nil
        resto = nil
        capcode = nil
        semanticURL = nil
        replies = nil
        images = nil
        uniqueIPS = nil
        country = nil
        countryName = nil
    }
}
