//
//  BoardsModalViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import RealmSwift


class BoardsModalViewController: UITableViewController {

    @IBOutlet var boardsTable: UITableView!
    
    var boards = [BoardRealm]()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        cell.textLabel?.text = self.boards[indexPath.row].board + " - " + self.boards[indexPath.row].title
        return cell
    }
    
    @objc func toggleEditMode() {
        print("pach")
        boardsTable.setEditing(!boardsTable.isEditing, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getBoards { boards in
            let x = boards!.boards
            if boards == nil || boards?.boards == nil {
                return
            }
            
//            self.boards = boards?.boards!
            self.tableView.reloadData()
            
        }
        
//        title = "Boards"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        boardsTable.dataSource = self

        let indexPath = IndexPath(row: 0, section: 0)
        boardsTable.insertRows(at: [indexPath], with: .automatic)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reorder", style: .plain, target: self, action: #selector(toggleEditMode))
        navigationItem.searchController = UISearchController()
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        // Do any additional setup after loading the view.
    }


    /**
     Gets list of boards. Updated every 15 minutes.
     */
    private func getBoards(callback: @escaping (BoardsRealm?) -> ()) {
        let realm = try! Realm()
        let settings = realm.objects(Settings.self)
        
        let boardsLastSyncedDate = settings[0].boardsLastSyncedDate
        
        let intervalSinceLastSync = Date().timeIntervalSince(boardsLastSyncedDate ?? Date(timeIntervalSince1970: 0))
        let fiveteenMinutes = TimeInterval(exactly: 1500000)! // TODO: Change to 15 * 60!
        if intervalSinceLastSync < fiveteenMinutes && realm.objects(BoardsRealm.self).count > 0 {
            NSLog("BoardsModalViewController#getBoards: Reading boards from realm...")
            callback(realm.objects(BoardsRealm.self)[0])
        } else {
            NSLog("BoardsModalViewController#getBoards: Fetching boards from api...")

            Requests.boards(success: { (boardsJSON) in

                var r = BoardsRealm()
                
                try! realm.write {
                    realm.delete(realm.objects(BoardsRealm.self))
                    
                    // Convert Alamofire -> Realm (ints to bools etc.)
//                    r.boards = [BoardRealm]()
//                    r.trollFlags = [TrollFlagRealm]()
                    
                    boardsJSON.boards.forEach {
                        let b = BoardRealm()
                        b.board = $0.board
                        b.title = $0.title
                        b.wsBoard = $0.wsBoard != 0
                        b.perPage = $0.perPage
                        b.pages = $0.pages
                        b.maxFilesize = $0.maxFilesize
                        b.maxWebmFilesize = $0.maxWebmFilesize
                        b.maxCommentChars = $0.maxCommentChars
                        b.maxWebmDuration = $0.maxWebmDuration
                        b.bumpLimit = $0.bumpLimit
                        b.imageLimit = $0.imageLimit
                        b.metaDescription = $0.metaDescription
                        b.isArchived = $0.isArchived != 0
                        b.spoilers = $0.spoilers != 0
                        
                        let c = CooldownsRealm()
                        c.images = $0.cooldowns.images
                        c.replies = $0.cooldowns.replies
                        c.threads = $0.cooldowns.threads
                        
                        b.cooldowns = c
                        b.customSpoilers.value = $0.customSpoilers
                        b.forcedAnon = $0.forcedAnon != 0
                        b.userIDS = $0.userIDS != 0
                        b.countryFlags = $0.countryFlags != 0
                        b.codeTags = $0.codeTags != 0
                        b.webmAudio = $0.webmAudio != 0
                        
                        b.minImageWidth.value = $0.minImageWidth
                        b.minImageHeight.value = $0.minImageHeight
                        b.oekaki = $0.oekaki != 0
                        b.sjisTags = $0.sjisTags != 0
                        b.textOnly = $0.textOnly != 0
                        b.requireSubject = $0.requireSubject != 0
                        b.trollFlags = $0.trollFlags != 0
                        b.mathTags = $0.mathTags != 0
                        
                        r.boards.append(b)
                    }
                    
                    
                    boardsJSON.trollFlags.forEach { (key, value) in
                        let t = TrollFlagRealm()
                        t.key = key
                        t.value = value
                        
                        r.trollFlags.append(t)
                    }
                    
                    realm.add(r)
                    settings[0].boardsLastSyncedDate = Date()
                }

                callback(r)
            }) { (error) in
                callback(nil)
            }
        }
    }
}

