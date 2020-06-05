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


class CatalogThreadRealm: Object {
    @objc dynamic var board = ""
    @objc dynamic var no = 0
    @objc dynamic var sticky = 0
    @objc dynamic var closed = 0
    @objc dynamic var now = ""
    @objc dynamic var name = ""
    @objc dynamic var sub = ""
    @objc dynamic var com = ""
    @objc dynamic var filename = ""
    @objc dynamic var ext = ""
    var image: Data? = nil
    @objc dynamic var lastAccessed: Date? = Date()
    @objc dynamic var page = 1
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
//    var lastReplies = List<LastReplyRealm>()
//    @objc dynamic var lastModified = 0
//    @objc dynamic var bumplimit = 0
//    @objc dynamic var imagelimit = 0
//    @objc dynamic var trip = ""
}
