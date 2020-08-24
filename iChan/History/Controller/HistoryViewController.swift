//
//  HistoryViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 24/08/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit

class HistoryViewController : UITableViewController {
    
    var dataSource = [VisitedThread]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dataSource = VisitedThread.getFromHistory()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.textLabel?.text = dataSource[indexPath.row].board + " - " + String(dataSource[indexPath.row].threadNo)
        return cell
    }
}
