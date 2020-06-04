//
//  FirstViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import RealmSwift
import Cards

class BookmarksViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [BookmarkElement]()
    
    override func viewDidLoad() {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidLoad()
        
        dataSource.append(
            BookmarkElement(board: "int", threadNo: 23, title: "thread 1", newRepliesCnt: 0)
        )
        
        dataSource.append(
            BookmarkElement(board: "int", threadNo: 123, title: "thread 2", newRepliesCnt: 3)
        )
        
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.dataSource.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension BookmarksViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let board = "/\(dataSource[indexPath.item].board)/"
        let title = dataSource[indexPath.item].title
        let newRepliesCnt: String = {
            if self.dataSource[indexPath.item].newRepliesCnt == 0 {
                return ""
            } else {
                return "(+\(self.dataSource[indexPath.item].newRepliesCnt))"
            }
        }()
        
        let label = "\(board) - \(title) \(newRepliesCnt)"
        
        cell.textLabel?.text = label
        return cell
    }
    
    
}
