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
    
    var boards = [Board]()
    
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
            if boards == nil || boards?.boards == nil {
                return
            }
            
            self.boards = boards!.boards
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
    private func getBoards(callback: @escaping (Boards?) -> ()) {
        let realm = try! Realm()
        let settings = realm.objects(Settings.self)
        
        let boardsLastSyncedDate = settings[0].boardsLastSyncedDate
        
        let intervalSinceLastSync = Date().timeIntervalSince(boardsLastSyncedDate ?? Date(timeIntervalSince1970: 0))
        let fiveteenMinutes = TimeInterval(exactly: 15 )! // TODO: Change to 15 * 60!
        if intervalSinceLastSync < fiveteenMinutes && realm.objects(Boards.self).count > 0 {
            NSLog("BoardsModalViewController#getBoards: Reading boards from realm...")
            callback(realm.objects(Boards.self)[0])
        } else {
            NSLog("BoardsModalViewController#getBoards: Fetching boards from api...")
     
            Requests.boards(success: { (boards) in
                
                try! realm.write {
                    realm.delete(realm.objects(Boards.self))
                    realm.add(boards)
                    settings[0].boardsLastSyncedDate = Date()
                }
                
                callback(boards)
            }) { (error) in
                callback(nil)
            }
        }
    }
}

