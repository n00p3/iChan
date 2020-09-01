//
//  HistoryViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 24/08/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit

class HistoryViewController : UITableViewController, UISearchBarDelegate {
    
    var searchController = UISearchController()
    
    var dataSource = [VisitedThread]()
    var filteredDataSource = [VisitedThread]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredDataSource = dataSource.filter {
            $0.board.lowercased().contains(searchText.lowercased()) ||
            $0.subject.lowercased().contains(searchText.lowercased()) ||
            $0.comment.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.searchBar.delegate = self
            
        dataSource = VisitedThread.getFromHistory()
        filteredDataSource = dataSource
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        var content = ""
        if filteredDataSource[indexPath.row].subject.count == 0 && filteredDataSource[indexPath.row].comment.count == 0 {
            content = "[no comment]"
        } else if filteredDataSource[indexPath.row].subject.count > 0 && filteredDataSource[indexPath.row].comment.count == 0 {
            content = filteredDataSource[indexPath.row].subject
        } else if filteredDataSource[indexPath.row].subject.count == 0 && filteredDataSource[indexPath.row].comment.count > 0 {
            content = filteredDataSource[indexPath.row].comment
        } else if filteredDataSource[indexPath.row].subject.count > 0 && filteredDataSource[indexPath.row].comment.count > 0 {
            content = filteredDataSource[indexPath.row].subject + " - " + filteredDataSource[indexPath.row].comment
        }
        
        content = filteredDataSource[indexPath.row].board + " - " + content
        let attrs: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: cell.textLabel?.font.pointSize ?? 12)
        ]
        
        cell.textLabel?.attributedText = content.htmlToAttributedString(attrs: attrs)
        cell.textLabel?.lineBreakMode = .byTruncatingTail
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Emit change on set / set value on emit.
        DataHolder.shared.currentThread = CurrentThread(
            threadNo: filteredDataSource[indexPath.row].threadNo,
            board: filteredDataSource[indexPath.row].board)
        
        DataHolder.shared.threadChangedEvent.emit(
            CurrentThread(
                threadNo: filteredDataSource[indexPath.row].threadNo,
                board: filteredDataSource[indexPath.row].board))
        
        searchController.isActive = false
        
        self.tabBarController?.selectedIndex = 2
    }
}
