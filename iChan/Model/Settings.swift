//
//  Settings.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

class ThreadIdentifier : Object {
    var board: String?
    var no: Int?
}

class Settings: Object {
    @objc dynamic var boardsLastSyncedDate: Date?
    @objc dynamic var currentBoard = "a"
}
