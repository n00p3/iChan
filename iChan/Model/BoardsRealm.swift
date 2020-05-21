//
//  BoardsRealm.swift
//  iChan
//
//  Created by Mateusz Głowski on 21/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation


import Foundation
import RealmSwift

class BoardsRealm: Object {
    var boards = List<BoardRealm>()
    var trollFlags = List<TrollFlagRealm>()
}

class TrollFlagRealm: Object {
    @objc dynamic var key = ""
    @objc dynamic var value = ""
}

class BoardRealm: Object {
    @objc dynamic var board = ""
    @objc dynamic var title = ""
    @objc dynamic var wsBoard = false
    @objc dynamic var perPage = 0
    @objc dynamic var pages = 0
    @objc dynamic var maxFilesize = 0
    @objc dynamic var maxWebmFilesize = 0
    @objc dynamic var maxCommentChars = 0
    @objc dynamic var maxWebmDuration = 0
    @objc dynamic var bumpLimit = 0
    @objc dynamic var imageLimit: Int = 0
    @objc dynamic var cooldowns: CooldownsRealm? = nil
    @objc dynamic var metaDescription = ""
    @objc dynamic var isArchived = false
    @objc dynamic var spoilers = false
    let customSpoilers = RealmOptional<Int>()
    @objc dynamic var forcedAnon = false
    @objc dynamic var userIDS = false
    @objc dynamic var countryFlags = false
    @objc dynamic var codeTags = false
    @objc dynamic var webmAudio = false
    let minImageWidth = RealmOptional<Int>()
    let minImageHeight = RealmOptional<Int>()
    @objc dynamic var oekaki = false
    @objc dynamic var sjisTags = false
    @objc dynamic var textOnly = false
    @objc dynamic var requireSubject = false
    @objc dynamic var trollFlags = false
    @objc dynamic var mathTags = false
}

class CooldownsRealm: Object {
    @objc dynamic var threads = 0
    @objc dynamic var replies = 0
    @objc dynamic var images = 0
}
