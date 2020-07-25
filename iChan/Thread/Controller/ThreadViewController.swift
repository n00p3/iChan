//
//  ThreadViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 25/07/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit

class ThreadViewController : UITableViewController {
    var dataSource = [
        ThreadCellModel(imgUrl: "x", author: "Anonymous", dateTime: Date(), no: 1234567890, comment: "Lorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsumLorem ipsum lorem ipsum lorem ipsum test test test test test test test test test test test test "),
        ThreadCellModel(imgUrl: nil, author: "Anonymous", dateTime: Date(), no: 1234567890, comment: "Lorem ipsum lorem ipsum lorem ipsum"),
        ThreadCellModel(imgUrl: "x", author: "Anonymous", dateTime: Date(), no: 1234567890, comment: "test"),
//        ThreadCellModel(imgUrl: "", author: "Anonymous", dateTime: Date(), no: 1234567890, comment: "Lorem ipsum lorem ipsum lorem ipsum"),
//        ThreadCellModel(imgUrl: "", author: "Anonymous", dateTime: Date(), no: 1234567890, comment: "Lorem ipsum lorem ipsum lorem ipsum"),
    ]
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var x = CGFloat(8.0)
        
        if dataSource[indexPath.row].imgUrl != nil {
            let img = UIImageView()
            img.frame = CGRect(x: x, y: 8, width: 100, height: 100)
            img.backgroundColor = .gray
        
            cell.addSubview(img)
            
            x = CGFloat(116.0)
        }
        
        let header = UILabel()
        header.text = "Anonymous 2020-01-01(Sat) 18:00:00 No.1234567890"
        header.adjustsFontSizeToFitWidth = true
        header.minimumScaleFactor = 0.5
        header.frame =  CGRect(x: x, y: 8, width: tableView.frame.width - 124, height: 12)
        
        cell.addSubview(header)
        
        let comment = UILabel()
        comment.numberOfLines = 0
        comment.lineBreakMode = .byWordWrapping
        comment.text = dataSource[indexPath.row].comment
        comment.frame = CGRect(x: x, y: 8, width: tableView.frame.width - 124, height: CGFloat.greatestFiniteMagnitude)
        comment.sizeToFit()
        comment.frame = CGRect(x: comment.frame.origin.x, y: 24, width: comment.frame.width, height: comment.frame.height)
        
        cell.contentView.addSubview(comment)
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("K")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = UILabel()
        comment.numberOfLines = 0
        comment.lineBreakMode = .byWordWrapping
        comment.text = dataSource[indexPath.row].comment
        comment.frame = CGRect(x: 116, y: 8, width: tableView.frame.width - 124, height: CGFloat.greatestFiniteMagnitude)
        comment.sizeToFit()
//        print(comment.frame)
        
        if comment.frame.height < 116 {
            return 116
        }
        return comment.frame.height + 32
    }
}
