//
//  Settings.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

class Settings: Object {
    @objc dynamic var boardsLastSyncedDate: Date?
    @objc dynamic var currentBoard = "a"
}
