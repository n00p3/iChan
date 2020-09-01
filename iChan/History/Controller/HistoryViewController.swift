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

        var content = ""
        if dataSource[indexPath.row].subject.count == 0 && dataSource[indexPath.row].comment.count == 0 {
            content = "[no comment]"
        } else if dataSource[indexPath.row].subject.count > 0 && dataSource[indexPath.row].comment.count == 0 {
            content = dataSource[indexPath.row].subject
        } else if dataSource[indexPath.row].subject.count == 0 && dataSource[indexPath.row].comment.count > 0 {
            content = dataSource[indexPath.row].comment
        } else if dataSource[indexPath.row].subject.count > 0 && dataSource[indexPath.row].comment.count > 0 {
            content = dataSource[indexPath.row].subject + " - " + dataSource[indexPath.row].comment
        }
        
        content = dataSource[indexPath.row].board + " - " + content
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
            threadNo: dataSource[indexPath.row].threadNo,
            board: dataSource[indexPath.row].board)
        
        DataHolder.shared.threadChangedEvent.emit(
            CurrentThread(
                threadNo: dataSource[indexPath.row].threadNo,
                board: dataSource[indexPath.row].board))
        self.tabBarController?.selectedIndex = 2
    }
}
