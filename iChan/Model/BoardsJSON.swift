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

struct BoardsJSON: Codable {
    let boards: [BoardJSON]
    let trollFlags: [String : String]

    enum CodingKeys: String, CodingKey {
        case boards
        case trollFlags = "troll_flags"
    }
}

struct BoardJSON: Codable {
    let board, title: String
    let wsBoard, perPage, pages, maxFilesize: Int
    let maxWebmFilesize, maxCommentChars, maxWebmDuration, bumpLimit: Int
    let imageLimit: Int
    let cooldowns: CooldownsJSON
    let metaDescription: String
    let isArchived, spoilers, customSpoilers, forcedAnon: Int?
    let userIDS, countryFlags, codeTags, webmAudio: Int?
    let minImageWidth, minImageHeight, oekaki, sjisTags: Int?
    let textOnly, requireSubject, trollFlags, mathTags: Int?

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

struct CooldownsJSON: Codable {
    let threads, replies, images: Int
}
