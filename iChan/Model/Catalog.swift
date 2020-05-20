//
//  Catalog.swift
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


struct CatalogElement: Codable {
    let page: Int
    let threads: [CatalogThread]
}

struct CatalogThread: Codable {
    let no: Int
    let sticky, closed: Int?
    let now, name: String
    let sub: String?
    let com: String?
    let filename: String
    let ext: EXT
    let w, h, tnW, tnH: Int
    let tim, time: Int
    let md5: String
    let fsize, resto: Int
    let capcode: String?
    let semanticURL: String
    let replies, images: Int
    let omittedPosts, omittedImages: Int?
    let lastReplies: [LastReply]?
    let lastModified: Int
    let bumplimit, imagelimit: Int?
    let trip: String?

    enum CodingKeys: String, CodingKey {
        case no, sticky, closed, now, name, sub, com, filename, ext, w, h
        case tnW = "tn_w"
        case tnH = "tn_h"
        case tim, time, md5, fsize, resto, capcode
        case semanticURL = "semantic_url"
        case replies, images
        case omittedPosts = "omitted_posts"
        case omittedImages = "omitted_images"
        case lastReplies = "last_replies"
        case lastModified = "last_modified"
        case bumplimit, imagelimit, trip
    }
}

enum EXT: String, Codable {
    case gif = ".gif"
    case jpg = ".jpg"
    case pdf = ".pdf"
    case png = ".png"
    case webm = ".webm"
}

struct LastReply: Codable {
    let no: Int
    let now, name: String
    let com: String?
    let filename: String?
    let ext: EXT?
    let w, h, tnW, tnH: Int?
    let tim: Int?
    let time: Int
    let md5: String?
    let fsize: Int?
    let resto: Int
    let capcode, trip: String?
    let filedeleted: Int?

    enum CodingKeys: String, CodingKey {
        case no, now, name, com, filename, ext, w, h
        case tnW = "tn_w"
        case tnH = "tn_h"
        case tim, time, md5, fsize, resto, capcode, trip, filedeleted
    }
}

typealias Catalog = [CatalogElement]
