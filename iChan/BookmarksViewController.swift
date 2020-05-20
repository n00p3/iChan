//
//  FirstViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import RealmSwift

class BookmarksViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Requests.posts("g", no: 75990090, success: { posts in
//            NSLog("ok")
            
        do {
            let realm = try Realm()
            
            let cnt = realm.objects(Posts.self)
            print("cnt: \(cnt)")
            
//                try realm.write {
//                    realm.add(posts)
//                }
            
        } catch {
            NSLog("Catch")
        }
            
//        }) { (error) in
//            NSLog(error.localizedDescription)
//        }
        
//        Requests.boards(success: { boards in
//            do {
//                let json = try String(data: JSONEncoder().encode(boards), encoding: String.Encoding.utf8)!
//                NSLog(json)
//
//                let realm = try Realm()
//
//                let o = realm.objects(BoardsR.self)
//
////                try realm.write {
////                    realm.add(boards)
////                }
//
//            } catch {
//                NSLog("Yikes")
//            }

//        }, failure: { error in
//            NSLog(error.localizedDescription)
//        })
    }


}

