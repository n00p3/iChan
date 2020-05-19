//
//  BoardsModalViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit

class BoardsModalViewController: UITableViewController {

    @IBOutlet var boardsTable: UITableView!
    
    var boards = ["uwu", "owo"]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell")!
        cell.textLabel?.text = self.boards[indexPath.row]
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
        title = "Boards"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        boardsTable.dataSource = self

        let indexPath = IndexPath(row: 0, section: 0)
        boardsTable.insertRows(at: [indexPath], with: .automatic)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reorder", style: .plain, target: self, action: #selector(toggleEditMode))
        navigationItem.searchController = UISearchController()
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        // Do any additional setup after loading the view.
    }


}

