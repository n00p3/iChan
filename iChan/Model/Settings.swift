//
//  Settings.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentThreadRealm : Object {
    @objc dynamic var board: String?
    @objc dynamic var no: Int = 0
}

class Settings: Object {
    @objc dynamic var boardsLastSyncedDate: Date?
    @objc dynamic var currentBoardInCatalog = ""
    @objc dynamic var currentThread: CurrentThreadRealm?

}
