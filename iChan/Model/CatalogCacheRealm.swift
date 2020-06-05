//
//  CatalogRealm.swift
//  iChan
//
//  Created by Mateusz Głowski on 05/06/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

//
//class CatalogCacheRealm: Object {
//    @objc dynamic var page = 1
//    var threads = List<CatalogThreadRealm>()
//}
//
//class CatalogThreadRealm: Object {
//    @objc dynamic var no = 0
//    @objc dynamic var sticky = false
//    @objc dynamic var closed = false
//    @objc dynamic var now: Date? = Date()
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
//    var lastReplies = List<LastReplyRealm>()
//    @objc dynamic var lastModified = 0
//    @objc dynamic var bumplimit = 0
//    @objc dynamic var imagelimit = 0
//    @objc dynamic var trip = ""
//}
//
//
//class LastReplyRealm: Object {
//    @objc dynamic var no = 0
//    @objc dynamic var now = 
//    @objc dynamic var now, name: String?
//    @objc dynamic var com: String?
//    @objc dynamic var filename: String?
//    @objc dynamic var ext: String?
//    @objc dynamic var w, h, tnW, tnH: Int?
//    @objc dynamic var tim: Int?
//    @objc dynamic var time: Int?
//    @objc dynamic var md5: String?
//    @objc dynamic var fsize: Int?
//    @objc dynamic var resto: Int?
//    @objc dynamic var capcode, trip: String?
//    @objc dynamic var filedeleted: Int?
//}
//
//typealias CatalogRealm = [CatalogCacheRealm]
