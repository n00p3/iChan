//
//  Utils.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

extension Date {
    func toRFC1123() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM YYYY HH:mm:SS 'GMT'"
        return formatter.string(from: self)
    }
}

func initDB() {
    let realm = try! Realm()
    let settings = realm.objects(Settings.self)
    if settings.count != 0 {
        return
    }
    
    try! realm.write {
        realm.add(Settings())
    }
}
