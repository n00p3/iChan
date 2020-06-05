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
import RealmSwift

class CatalogElement: Object, Codable {
    @objc dynamic var page = 0
    let threads = List<CatalogThread>()
}

class CatalogThread: Object, Codable {
    @objc dynamic var no = 0
    @objc dynamic var sticky = 0
    @objc dynamic var closed = 0
    @objc dynamic var now = ""
    @objc dynamic var name = ""
    @objc dynamic var sub = ""
    @objc dynamic var com = ""
    @objc dynamic var filename = ""
    @objc dynamic var ext = ""
    @objc dynamic var w = 0
    @objc dynamic var h = 0
    @objc dynamic var tnW = 0
    @objc dynamic var tnH = 0
    @objc dynamic var tim = 0
    @objc dynamic var time = 0
    @objc dynamic var md5 = ""
    @objc dynamic var fsize = 0
    @objc dynamic var resto = 0
    @objc dynamic var capcode = ""
    @objc dynamic var semanticURL = ""
    @objc dynamic var replies = 0
    @objc dynamic var images = 0
    @objc dynamic var omittedPosts = 0
    @objc dynamic var omittedImages = 0
    let lastReplies = List<LastReply>()
    @objc dynamic var lastModified = 0
    @objc dynamic var bumplimit = 0
    @objc dynamic var imagelimit = 0
    @objc dynamic var trip: String = ""

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


class LastReply: Object, Codable {
    @objc dynamic var no = 0
    @objc dynamic var now = ""
    @objc dynamic var name = ""
    @objc dynamic var com = ""
    @objc dynamic var filename = ""
    @objc dynamic var ext = ""
    @objc dynamic var w = 0
    @objc dynamic var h = 0
    @objc dynamic var tnW = 0
    @objc dynamic var tnH = 0
    @objc dynamic var tim = 0
    @objc dynamic var time = 0
    @objc dynamic var md5 = ""
    @objc dynamic var fsize = 0
    @objc dynamic var resto = 0
    @objc dynamic var capcode = ""
    @objc dynamic var trip = ""
    @objc dynamic var filedeleted = 0

    enum CodingKeys: String, CodingKey {
        case no, now, name, com, filename, ext, w, h
        case tnW = "tn_w"
        case tnH = "tn_h"
        case tim, time, md5, fsize, resto, capcode, trip, filedeleted
    }
}

typealias Catalog = [CatalogElement]

//--------

class CatalogElement2: Object, Mappable {
    @objc dynamic var page = 0
    let threads = List<CatalogThread2>()
    
    func mapping(map: Map) {
        
    }
}

class CatalogThread2: Object {
    @objc dynamic var no = 0
//    @objc dynamic var sticky = 0
//    @objc dynamic var closed = 0
//    @objc dynamic var now = ""
//    @objc dynamic var name = ""
//    @objc dynamic var sub = ""
//    @objc dynamic var com = ""
//    @objc dynamic var filename = ""
//    @objc dynamic var ext = ""
//    @objc dynamic var w = 0
//    @objc dynamic var h = 0
//    @objc dynamic var tnW = 0
//    @objc dynamic var tnH = 0
//    @objc dynamic var tim = 0
//    @objc dynamic var time = 0
//    @objc dynamic var md5 = ""
//    @objc dynamic var fsize = 0
//    @objc dynamic var resto = 0
//    @objc dynamic var capcode = ""
//    @objc dynamic var semanticURL = ""
//    @objc dynamic var replies = 0
//    @objc dynamic var images = 0
//    @objc dynamic var omittedPosts = 0
//    @objc dynamic var omittedImages = 0
//    let lastReplies = List<LastReply>()
//    @objc dynamic var lastModified = 0
//    @objc dynamic var bumplimit = 0
//    @objc dynamic var imagelimit = 0
//    @objc dynamic var trip: String = ""

//    enum CodingKeys: String, CodingKey {
//        case no
//        , sticky, closed, now, name, sub, com, filename, ext, w, h
//        case tnW = "tn_w"
//        case tnH = "tn_h"
//        case tim, time, md5, fsize, resto, capcode
//        case semanticURL = "semantic_url"
//        case replies, images
//        case omittedPosts = "omitted_posts"
//        case omittedImages = "omitted_images"
//        case lastReplies = "last_replies"
//        case lastModified = "last_modified"
//        case bumplimit, imagelimit, trip
//    }
}


class LastReply2: Object {
    @objc dynamic var no = 0
    @objc dynamic var now = ""
    @objc dynamic var name = ""
    @objc dynamic var com = ""
    @objc dynamic var filename = ""
    @objc dynamic var ext = ""
    @objc dynamic var w = 0
    @objc dynamic var h = 0
    @objc dynamic var tnW = 0
    @objc dynamic var tnH = 0
    @objc dynamic var tim = 0
    @objc dynamic var time = 0
    @objc dynamic var md5 = ""
    @objc dynamic var fsize = 0
    @objc dynamic var resto = 0
    @objc dynamic var capcode = ""
    @objc dynamic var trip = ""
    @objc dynamic var filedeleted = 0

//    enum CodingKeys: String, CodingKey {
//        case no, now, name, com, filename, ext, w, h
//        case tnW = "tn_w"
//        case tnH = "tn_h"
//        case tim, time, md5, fsize, resto, capcode, trip, filedeleted
//    }
}

typealias Catalog2 = [CatalogElement2]

