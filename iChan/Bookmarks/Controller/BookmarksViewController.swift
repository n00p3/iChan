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
    var buttonRemoveAllBookmarks: UIBarButtonItem?
    
    var dataSource: [BookmarkElement] = [BookmarkElement]() {
        didSet {
            updateDeletionButton()
        }
    }
    
    private func updateDeletionButton() {
        buttonRemoveAllBookmarks?.isEnabled = self.dataSource.count > 0
    }
    
    @objc private func deleteAllBookmarksClicked(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Deleting all bookmarks", message: "Are you sure you want to delete all bookmarks?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { _ in self.deleteAllBookmarksClickedHandler() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteAllBookmarksClickedHandler() {
        for i in (0..<self.dataSource.count).reversed() {
            self.dataSource.remove(at: i)
            self.tableView.deleteRows(at: [IndexPath(item: i, section: 0)], with: .automatic)
        }
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidLoad()
        
        buttonRemoveAllBookmarks = UIBarButtonItem(title: "Delete all", style: .plain, target: self, action: #selector(deleteAllBookmarksClicked(_:)))
        navigationItem.rightBarButtonItem = buttonRemoveAllBookmarks
        
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
