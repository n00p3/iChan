//
//  DataHolder.swift
//  iChan
//
//  Created by Mateusz Głowski on 23/07/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import EmitterKit
import RealmSwift

struct DataHolder {
    static var shared = DataHolder()
    
    var currentCatalogBoard: String = "" {
        didSet {
            let realm = try! Realm()
            try! realm.write {
                let sett = realm.objects(Settings.self).first!
                sett.currentBoardInCatalog = currentCatalogBoard
            }
        }
    }
    
    var currentThread: CurrentThread = CurrentThread(threadNo: 0, board: "") {
        didSet {
            let realm = try! Realm()
            try! realm.write {
                let sett = realm.objects(Settings.self).first!
                let t = CurrentThreadRealm()
                t.board = currentThread.board
                t.no = currentThread.threadNo
                sett.currentThread = t
            }
            VisitedThread.addToHistory(threadNo: currentThread.threadNo, board: currentThread.board)
            print(realm.objects(Settings.self).first!.currentThread)
        }
    }
    var threadChangedEvent = Event<CurrentThread>()
    
    init() {
        let realm = try! Realm()
        let settings = realm.objects(Settings.self).first
        currentThread = CurrentThread(
            threadNo: settings?.currentThread?.no ?? 0,
            board: settings?.currentThread?.board ?? "")
        currentCatalogBoard = settings?.currentBoardInCatalog ?? "g"
    }
}
