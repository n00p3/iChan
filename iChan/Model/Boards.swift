//
//  Board.swift
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

class Boards: Object, Codable {
    @objc dynamic let boards: [Board]
    let trollFlags: [String : String]

    enum CodingKeys: String, CodingKey {
        case boards
        case trollFlags = "troll_flags"
    }
}

class Board: Object, Codable {
    @objc dynamic let board: String
    @objc dynamic let title: String
    @objc dynamic let wsBoard: Int
    @objc dynamic let perPage: Int
    @objc dynamic let pages: Int
    @objc dynamic let maxFilesize: Int
    @objc dynamic let maxWebmFilesize: Int
    @objc dynamic let maxCommentChars: Int
    @objc dynamic let maxWebmDuration: Int
    @objc dynamic let bumpLimit: Int
    @objc dynamic let imageLimit: Int
    let cooldowns: [String : Int]
    @objc dynamic let metaDescription: String
    let isArchived: Int?
    let spoilers: Int?
    let customSpoilers: Int?
    let forcedAnon: Int?
    let userIDS: Int?
    let countryFlags: Int?
    let codeTags: Int?
    let webmAudio: Int?
    let minImageWidth: Int?
    let minImageHeight: Int?
    let oekaki: Int?
    let sjisTags: Int?
    let textOnly: Int?
    let requireSubject: Int?
    let trollFlags: Int?
    let mathTags: Int?

    enum CodingKeys: String, CodingKey {
        case board, title
        case wsBoard = "ws_board"
        case perPage = "per_page"
        case pages
        case maxFilesize = "max_filesize"
        case maxWebmFilesize = "max_webm_filesize"
        case maxCommentChars = "max_comment_chars"
        case maxWebmDuration = "max_webm_duration"
        case bumpLimit = "bump_limit"
        case imageLimit = "image_limit"
        case cooldowns
        case metaDescription = "meta_description"
        case isArchived = "is_archived"
        case spoilers
        case customSpoilers = "custom_spoilers"
        case forcedAnon = "forced_anon"
        case userIDS = "user_ids"
        case countryFlags = "country_flags"
        case codeTags = "code_tags"
        case webmAudio = "webm_audio"
        case minImageWidth = "min_image_width"
        case minImageHeight = "min_image_height"
        case oekaki
        case sjisTags = "sjis_tags"
        case textOnly = "text_only"
        case requireSubject = "require_subject"
        case trollFlags = "troll_flags"
        case mathTags = "math_tags"
    }
}

class Cooldowns: Object, Codable {
    let threads: Int
    let replies: Int
    let images: Int
    
    enum CodingKeys: String, CodingKey {
        case threads, replies, images
    }
}
