//
//  BookmarksRealm.swift
//  iChan
//
//  Created by Mateusz Głowski on 25/07/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

class BookmarkRealm: Object {
    @objc dynamic var board: String = ""
    @objc dynamic var threadNo: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var repliesCnt: Int = 0
}

