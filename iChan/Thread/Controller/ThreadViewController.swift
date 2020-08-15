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
import EmitterKit
import Lightbox
import Player
import Presentr

class ThreadViewController : UITableViewController, PlayerDelegate, PlayerPlaybackDelegate {
    func playerReady(_ player: Player) {
        
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        
    }
    
    func playerCurrentTimeDidChange(_ player: Player) {
        
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        
    }
    
    let COM_FONT_SIZE = CGFloat(16)
    var dataSource = [Post]()
    var board = ""
    var listener: EventListener<CurrentThread>?
    let activityIndicator = UIActivityIndicatorView()
    private var selectedImageIndex = 0
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        activityIndicator.startAnimating()
        activityIndicator.center = CGPoint(x: view.center.x, y: UIScreen.main.bounds.height / 2)
        view.addSubview(activityIndicator)
        self.activityIndicator.alpha = 0
        
        Requests.posts(
            DataHolder.shared.currentThread.board,
            no: DataHolder.shared.currentThread.threadNo,
            success: { posts in
                self.dataSource = posts.posts
                self.setHeader(posts.posts.first?.sub)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.activityIndicator.alpha = 0
                    self.tableView.alpha = 1
                })
                
        }, failure: { e in
            SPAlert.present(title: "Error", message: "Couldn't fetch thread data.", preset: .error)
        })
        
        prepareEventListener()
    }
    
    private func prepareEventListener() {
        listener = DataHolder.shared.threadChangedEvent.on { data in
            self.activityIndicator.alpha = 1
            self.dataSource.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            Requests.posts(
                data.board,
                no: data.threadNo,
                success: { posts in
                    self.dataSource = posts.posts
                    self.setHeader(posts.posts.first?.sub)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.activityIndicator.alpha = 0
                        self.tableView.alpha = 1
                    })
                    
            }, failure: { e in
                SPAlert.present(title: "Error", message: "Couldn't fetch thread data.", preset: .error)
            })
            
        }
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
    
//    private func getThreadFiles() -> [URL] {
////        DataHolder.shared.currentThread.board
//        return dataSource
//            .filter { post in post.tim != nil && post.ext != nil }
//            .map { post in
//            URL(string: "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(post.tim!)\(post.ext!)")!
//        }
//    }
    
    @objc dynamic func viewFileSelector(_ gesture: UITapGestureRecognizer) {
        let filtered = dataSource.filter { $0.tim != nil && $0.ext != nil }
        let id = filtered.firstIndex(where: { String($0.tim ?? 0) == gesture.view?.accessibilityIdentifier })
        
        let preview = FilesPreview(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        preview.urls = self.dataSource.filter { $0.ext != nil }
        preview.currentPage = id ?? 0
        
        let presentr = Presentr(presentationType: .fullScreen)
        presentr.dismissOnSwipe = true
        customPresentViewController(presentr, viewController: preview, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var x = CGFloat(20)
        
        if dataSource[indexPath.row].filename != nil {
            let img = UIImageView()
            img.contentMode = .scaleAspectFill
            img.clipsToBounds = true
            img.frame = CGRect(x: x, y: 8, width: 100, height: 100)
            
            img.backgroundColor = .gray
        
            cell.addSubview(img)
            
            readImageForPost(board: DataHolder.shared.currentThread.board, postNo: dataSource[indexPath.row].no, callback: { i in
                img.image = i
                img.isUserInteractionEnabled = true
                let tim = self.dataSource[indexPath.row].tim ?? 0
                let ext = self.dataSource[indexPath.row].ext ?? ""
                img.accessibilityIdentifier = String(tim)
                img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewFileSelector(_:))))
            })
            
            x = CGFloat(128)
        }
        
        let header = UILabel()
        let author = dataSource[indexPath.row].name
        let dateTime = dataSource[indexPath.row].now
        let no = dataSource[indexPath.row].no
        header.text = "\(author) \(dateTime) \(no)"
        header.textColor = .gray
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
        comment.frame = CGRect(x: x, y: 8, width: tableView.frame.width - (x + 20), height: CGFloat.greatestFiniteMagnitude)
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
        var x = CGFloat(20)
        if dataSource[indexPath.row].filename != nil {
            x = CGFloat(128)
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
        comment.frame = CGRect(x: x, y: 8, width: tableView.frame.width - (x + 20), height: CGFloat.greatestFiniteMagnitude)
        comment.sizeToFit()
//        print(comment.frame)
        
        if comment.frame.height < 128 {
            return 128
        }
        return comment.frame.height + 32
    }
}
