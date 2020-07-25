//
//  ThreadViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 25/07/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import SPAlert
import RealmSwift

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
    
    private func readImageForPost(board: String, postNo: Int, callback: @escaping (UIImage?) -> ()) {
        let realm = try! Realm()
        let filter = "board == \"\(board)\" AND #no == \(postNo)"
        let storedThread = realm.objects(CatalogThreadRealm.self)
            .filter(filter)

        if storedThread.first?.image != nil {
//            print("local \(threadNo)")
            callback(UIImage(data: storedThread.first!.image!))
            return
        }
//        print("remote \(threadNo)")
        
        let x = self.dataSource.filter { $0.no == postNo }.first
        let ext = x?.ext ?? ""
        let tim = x?.tim ?? 0
        Requests.image(board, tim, ext, fullSize: false) { (img) in
//            card.backgroundImage = img
            if img?.pngData() != nil {
                self.storeImageForPost(board: board, postNo: postNo, data: img!.pngData()!)
            }
            callback(img)
        }
        
    }
    
    private func storeImageForPost(board: String, postNo: Int, data: Data) {
        let realm = try! Realm()

        try! realm.write {
            // Add image to stored thread if exists.
            // Has to escape 'no' using hash.
            let filter = "board = \"\(board)\" AND #no = \(postNo)"
            let storedThread = realm.objects(CatalogThreadRealm.self)
                .filter(filter)

            for thread in storedThread {
                thread.image = data
            }
        }
        
        let r2 = try! Realm()
        let filter = "board = \"\(board)\" AND #no = \(postNo)"
        _ = r2.objects(CatalogThreadRealm.self).filter(filter)
        
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
            img.contentMode = .scaleAspectFill
            img.clipsToBounds = true
            img.frame = CGRect(x: x, y: 8, width: 100, height: 100)
            
            img.backgroundColor = .gray
        
            cell.addSubview(img)
            
            // TODO: pass valid board automatically.
            readImageForPost(board: DataHolder.shared.threadBoard, postNo: dataSource[indexPath.row].no, callback: { i in
                img.image = i
            })
            
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
