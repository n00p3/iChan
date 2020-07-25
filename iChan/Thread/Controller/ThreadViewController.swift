//
//  ThreadViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 25/07/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import SPAlert

class ThreadViewController : UITableViewController {
    let COM_FONT_SIZE = CGFloat(16)
    var dataSource = [Post]()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        Requests.posts(
            "g",
            no: 76925041,
            success: { posts in
                self.dataSource = posts.posts
                self.setHeader(posts.posts.first?.sub)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }, failure: { e in
            SPAlert.present(title: "Error", message: "Couldn't fetch thread data.", preset: .error)
        })
    }
    
    private func setHeader(_ val: String?) {
        if val == nil {
            navigationItem.title = "Thread"
        } else {
            navigationItem.title = val!
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var x = CGFloat(8.0)
        
        if dataSource[indexPath.row].filename != nil {
            let img = UIImageView()
            img.frame = CGRect(x: x, y: 8, width: 100, height: 100)
            img.backgroundColor = .gray
        
            cell.addSubview(img)
            
            x = CGFloat(116.0)
        }
        
        let header = UILabel()
//        header.text = "Anonymous 2020-01-01(Sat) 18:00:00 No.1234567890"
        header.adjustsFontSizeToFitWidth = true
        header.minimumScaleFactor = 0.5
        header.frame =  CGRect(x: x, y: 8, width: tableView.frame.width - (x + 8), height: 12)
        
        cell.addSubview(header)
        
        let comment = UILabel()
        comment.font = comment.font.withSize(COM_FONT_SIZE)
        comment.numberOfLines = 0
        comment.lineBreakMode = .byWordWrapping
        let attrs: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: COM_FONT_SIZE)
        ]
        let attrStr = dataSource[indexPath.row].com?.htmlToAttributedString(attrs: attrs)
        comment.attributedText = attrStr
        comment.frame = CGRect(x: x, y: 8, width: tableView.frame.width - (x + 8), height: CGFloat.greatestFiniteMagnitude)
        comment.sizeToFit()
        comment.frame = CGRect(x: comment.frame.origin.x, y: 24, width: comment.frame.width, height: comment.frame.height)
        
        cell.contentView.addSubview(comment)
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var x = CGFloat(8.0)
        if dataSource[indexPath.row].filename != nil {
            x = CGFloat(116.0)
        }
        let comment = UILabel()
        comment.font = comment.font.withSize(COM_FONT_SIZE)
        comment.numberOfLines = 0
        comment.lineBreakMode = .byWordWrapping
        let attrs: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: COM_FONT_SIZE)
        ]
        let attrStr = dataSource[indexPath.row].com?.htmlToAttributedString(attrs: attrs)
        comment.attributedText = attrStr
        comment.frame = CGRect(x: 116, y: 8, width: tableView.frame.width - (x + 8), height: CGFloat.greatestFiniteMagnitude)
        comment.sizeToFit()
//        print(comment.frame)
        
        if comment.frame.height < 116 {
            return 116
        }
        return comment.frame.height + 32
    }
}
