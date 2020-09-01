//
//  VisitedThread.swift
//  iChan
//
//  Created by Mateusz Głowski on 24/08/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//
import Foundation
import RealmSwift

class VisitedThread: Object {
    @objc dynamic var threadNo = 0
    @objc dynamic var board = ""
    @objc dynamic var subject = ""
    @objc dynamic var comment = ""
    @objc dynamic var lastVisitedAt = Date()
    
    override class func primaryKey() -> String? {
        "threadNo"
    }
    
    static func getFromHistory() -> [VisitedThread] {
        let realm = try! Realm()
        let objs = realm.objects(VisitedThread.self)
        return objs.map { $0 }.sorted(by: { $0.lastVisitedAt > $1.lastVisitedAt })
    }
    
    static func addToHistory(threadNo: Int, board: String, subject: String, comment: String) {
        let realm = try! Realm()
        let obj = realm.objects(VisitedThread.self)
            .filter(NSPredicate(format: "threadNo = %d and board = %@", threadNo, board))
        if obj.count == 0 {
            try! realm.write {
                let temp = VisitedThread()
                temp.threadNo = threadNo
                temp.board = board
                temp.subject = subject
                temp.comment = comment
                temp.lastVisitedAt = Date()
                realm.add(temp).self
            }
        } else {
            try! realm.write {
                obj.first!.lastVisitedAt = Date()
            }
        }
        
        cleanUpHistory()
    }
    /**
     Removes old data.
     Keeps only 100 newest threads.
     */
    static func cleanUpHistory() {
        let realm = try! Realm()
        try! realm.write {
            let objs = realm.objects(VisitedThread.self)
                .sorted(by: { $0.lastVisitedAt > $1.lastVisitedAt }) // Newest first.
         
            if objs.count > 100 {
                for i in 100..<objs.count {
                    realm.delete(objs[i])
                }
            }
        }
    }
}
