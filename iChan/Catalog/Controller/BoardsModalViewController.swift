//
//  BoardsModalViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import RealmSwift


class BoardsModalViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    @IBOutlet var boardsTable: UITableView!
    var searchController: UISearchController?
    
    var myDelegate: CatalogBoardDelegate?
    @IBAction func boardChanged(_ sender: UIStoryboardSegue) {}
    
    var boards = [BoardRealm]()

    func updateSearchResults(for searchController: UISearchController) {
        let bs = try! Realm().objects(BoardsRealm.self)[0]
        boards = Array(bs.boards)
        
        self.searchController = searchController
        var search = searchController.searchBar.text
        
        if (search == nil || search!.isEmpty) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        search = search!.lowercased()
        
        self.boards = self.boards.filter { $0.board.lowercased().contains(search!) || $0.title.lowercased().contains(search!) }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
//    override func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        print("END")
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected \(boards[indexPath.item].board)")
        let realm = try! Realm()
        try! realm.write {
            let settings = realm.objects(Settings.self)
            settings.first?.currentBoardInCatalog = boards[indexPath.item].board
        }
        
        myDelegate?.boardChanged(newBoard: boards[indexPath.item].board)
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
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
        print("moved from \(sourceIndexPath.item) to \(destinationIndexPath.item)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "uwu"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        getBoards { boards in
            if boards == nil || boards?.boards == nil {
                return
            }

            self.boards = Array(boards!.boards)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        title = "Boards"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        boardsTable.dataSource = self

        let indexPath = IndexPath(row: 0, section: 0)
        boardsTable.insertRows(at: [indexPath], with: .automatic)
        
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
    }


    /**
     Gets list of boards. Updated every 15 minutes.
     */
    private func getBoards(callback: @escaping (BoardsRealm?) -> ()) {
        let realm = try! Realm()
        let settings = realm.objects(Settings.self)
        
        let boardsLastSyncedDate = settings[0].boardsLastSyncedDate
        
        let intervalSinceLastSync = Date().timeIntervalSince(boardsLastSyncedDate ?? Date(timeIntervalSince1970: 0))
        let fiveteenMinutes = TimeInterval(exactly: 5)! // TODO: Change to 15 * 60!
        if intervalSinceLastSync < fiveteenMinutes && realm.objects(BoardsRealm.self).count > 0 {
            NSLog("BoardsModalViewController#getBoards: Reading boards from realm...")
            let boards = realm.objects(BoardsRealm.self)[0]
            callback(boards)
        } else {
            NSLog("BoardsModalViewController#getBoards: Fetching boards from api...")

            Requests.boards(success: { (boardsJSON) in

                let r = BoardsRealm()
                
                try! realm.write {
                    let br = realm.objects(BoardsRealm.self)
      
                    realm.delete(br)
                    
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

