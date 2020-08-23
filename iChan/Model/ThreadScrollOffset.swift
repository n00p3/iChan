//
//  ThreadScrollOffset.swift
//  iChan
//
//  Created by Mateusz Głowski on 23/08/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

class ThreadScrollOffset: Object {
    @objc dynamic var threadNo = 0
    @objc dynamic var board = ""
    @objc dynamic var firstVisiblePost = 0
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    
    override class func primaryKey() -> String? {
        "threadNo"
    }
    
    static func setOffset(threadNo: Int, board: String, firstVisiblePost: Int) {
        let realm = try! Realm()
        try! realm.write {
            let obj = realm.objects(ThreadScrollOffset.self)
                .filter(NSPredicate(format: "threadNo = %d and board = %@", threadNo, board))
            
            if obj.count == 0 {
                let nVal = ThreadScrollOffset()
                nVal.threadNo = threadNo
                nVal.board = board
                nVal.firstVisiblePost = firstVisiblePost
                
                realm.add(nVal)
            } else {
                obj.first!.firstVisiblePost = firstVisiblePost
                obj.first!.updatedAt = Date()
            }
        }
        
        cleanUpOffsets()
    }
    
    static func getOffset(threadNo: Int, board: String) -> Int {
        let realm = try! Realm()
        let obj = realm.objects(ThreadScrollOffset.self)
            .filter(NSPredicate(format: "threadNo = %d and board = %@", threadNo, board))
        if obj.count == 0 {
            return 0
        } else {
            return obj.first!.firstVisiblePost
        }
    }
    /**
     Removes old data.
     Keeps only 100 newest threads.
     */
    static func cleanUpOffsets() {
        let realm = try! Realm()
        try! realm.write {
            let objs = realm.objects(ThreadScrollOffset.self)
                .sorted(by: { $0.updatedAt > $1.updatedAt }) // Newest first.
         
            if objs.count > 100 {
                for i in 100..<objs.count {
                    realm.delete(objs[i])
                }
            }
        }
    }
}
