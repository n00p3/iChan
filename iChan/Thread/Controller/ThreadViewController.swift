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
import Kingfisher

class ThreadViewController : UITableViewController, UISearchResultsUpdating {
    let COM_FONT_SIZE = CGFloat(16)
    var dataSourceFiltered = [Post]()
    var dataSource = [Post]()
    var highlightCellIndex: Int? = nil
    var listener: EventListener<CurrentThread>?
    let activityIndicator = UIActivityIndicatorView()
    private var selectedImageIndex = 0
    private var searchController = UISearchController()

    private func updateScrollLocationInDb(firstVisiblePost: Int) {
        ThreadScrollOffset.setOffset(
            threadNo: DataHolder.shared.currentThread.threadNo,
            board: DataHolder.shared.currentThread.board,
            firstVisiblePost: firstVisiblePost)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateScrollLocationInDb(firstVisiblePost: tableView.indexPathsForVisibleRows?.first?.row ?? 0)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateScrollLocationInDb(firstVisiblePost: tableView.indexPathsForVisibleRows?.first?.row ?? 0)
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        
        activityIndicator.startAnimating()
        activityIndicator.center = CGPoint(x: view.center.x, y: UIScreen.main.bounds.height / 2)

        activityIndicator.frame = view.bounds
        activityIndicator.backgroundColor = .systemBackground
        view.addSubview(activityIndicator)
//        self.activityIndicator.alpha = 0
        
        // Do not delete or the thread will not appear for the first time.
        Requests.posts(
            DataHolder.shared.currentThread.board,
            no: DataHolder.shared.currentThread.threadNo,
            success: { posts in
                self.dataSourceFiltered = posts.posts
                self.dataSource = posts.posts
                self.setHeader(posts.posts.first?.sub)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.layoutIfNeeded()
                    self.setScrollOffsetFromMemory()
                }
                
        }, failure: { e in
            SPAlert.present(title: "Error", message: "Couldn't fetch thread data.", preset: .error)
        })
        // ! Do not delete.
        
        prepareEventListener()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
             self.updateSearchDebounced()
        }
    }
    
    private func updateSearchDebounced() {
        dataSourceFiltered = dataSource
        
        if searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0 == 0 {
            tableView.reloadData()
            return
        }
        
        for i in (0..<dataSourceFiltered.count).reversed() {
            if !(dataSourceFiltered[i].com?.lowercased().contains(searchController.searchBar.text!.lowercased()) ?? false ||
                 dataSourceFiltered[i].sub?.lowercased().contains(searchController.searchBar.text!.lowercased()) ?? false ||
                 dataSourceFiltered[i].name?.lowercased().contains(searchController.searchBar.text!.lowercased()) ?? false ||
                 dataSourceFiltered[i].capcode?.lowercased().contains(searchController.searchBar.text!.lowercased()) ?? false) {
                dataSourceFiltered.remove(at: i)
            }
        }
        
        tableView.reloadData()
    }
    
    private func prepareEventListener() {
        listener = DataHolder.shared.threadChangedEvent.on { data in
            self.activityIndicator.alpha = 1
            self.dataSourceFiltered.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            Requests.posts(
                data.board,
                no: data.threadNo,
                success: { posts in
                    self.dataSourceFiltered = posts.posts
                    self.dataSource = posts.posts
                    
                    self.setHeader(posts.posts.first?.sub)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.layoutIfNeeded()
                        self.setScrollOffsetFromMemory()
                    }
            }, failure: { e in
                SPAlert.present(title: "Error", message: "Couldn't fetch thread data.", preset: .error)
            })
            
        }
    }
    
    private func setScrollOffsetFromMemory() {
        let firstVisiblePost = ThreadScrollOffset.getOffset(threadNo: DataHolder.shared.currentThread.threadNo, board: DataHolder.shared.currentThread.board)
        tableView.scrollToRow(at: IndexPath(row: firstVisiblePost, section: 0), at: .top, animated: false)
        UIView.animate(withDuration: 0.5) {
            self.activityIndicator.alpha = 0
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        
        let x = self.dataSourceFiltered.filter { $0.no == postNo }.first
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
            navigationItem.title = String(htmlEncodedString: val!)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSourceFiltered.count
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
        let filtered = dataSourceFiltered.filter { $0.tim != nil && $0.ext != nil }
        let id = filtered.firstIndex(where: { String($0.tim ?? 0) == gesture.view?.accessibilityIdentifier })
        
        let preview = FilesPreview(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        preview.urls = self.dataSourceFiltered.filter { $0.ext != nil }
        preview.currentPage = id ?? 0
        
        let presentr = Presentr(presentationType: .fullScreen)
        presentr.dismissOnSwipe = true
        customPresentViewController(presentr, viewController: preview, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if dataSourceFiltered.count == 0 {
            return cell
        }
        
        let header = UILabel()
        let headerDetails = UILabel()
        
        var x = CGFloat(20)
        let img = UIImageView()
        if dataSourceFiltered[indexPath.row].filename != nil {
            img.contentMode = .scaleAspectFill
            img.clipsToBounds = true
            img.frame = CGRect(x: x, y: 8, width: 100, height: 100)
            
            img.backgroundColor = .gray
        
            cell.addSubview(img)
            
            readImageForPost(board: DataHolder.shared.currentThread.board, postNo: dataSourceFiltered[indexPath.row].no, callback: { i in
                if indexPath.row >= self.dataSourceFiltered.count { return }
                
                img.image = i
                img.isUserInteractionEnabled = true
                let tim = self.dataSourceFiltered[indexPath.row].tim ?? 0
                let ext = self.dataSourceFiltered[indexPath.row].ext ?? ""
                img.accessibilityIdentifier = String(tim)
                img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewFileSelector(_:))))
                
                headerDetails.frame = CGRect(x: headerDetails.frame.origin.x, y: headerDetails.frame.origin.y, width: tableView.frame.width - (x + 16) - img.frame.width, height: headerDetails.frame.height)
            })
            
            x = CGFloat(128)
        }
        

        let author = dataSourceFiltered[indexPath.row].name ?? ""
        let dateTime = dataSourceFiltered[indexPath.row].now
        let no = dataSourceFiltered[indexPath.row].no
        
        let country = dataSourceFiltered[indexPath.row].country
        
        let countryFlag = UIImageView()

        header.text = author
        header.textColor = .gray
        header.adjustsFontSizeToFitWidth = true
        header.minimumScaleFactor = 0.5
        header.frame =  CGRect(x: x, y: 8, width: tableView.frame.width - (x + 8), height: 12)
        header.sizeToFit()
        
        headerDetails.text = "\(dateTime) \(no)"
        headerDetails.textColor = .gray
        headerDetails.adjustsFontSizeToFitWidth = true
        headerDetails.minimumScaleFactor = 0.5
        
        // TODO: Thread No. goes out of screen on iPhone 8.
        if country == nil {
            headerDetails.frame = CGRect(x: 8 + header.frame.origin.x + header.frame.width, y: 8, width: tableView.frame.width - (x + 8) - header.frame.width, height: 12)
        } else {
            countryFlag.kf.setImage(with: URL(string: "https://s.4cdn.org/image/country/\(country!.lowercased()).gif"))
            countryFlag.frame = CGRect(x: x + header.frame.width + 4, y: 12, width: 16, height: 11)
            cell.addSubview(countryFlag)
            
            headerDetails.frame = CGRect(x: 20 + countryFlag.frame.origin.x, y: 8, width: tableView.frame.width - (x + 16) - header.frame.width, height: 12)
        }
        headerDetails.sizeToFit()
        
        cell.addSubview(header)
        
        cell.addSubview(headerDetails)
        
        let comment = UILabel()
        comment.font = comment.font.withSize(COM_FONT_SIZE)
        comment.numberOfLines = 0
        comment.lineBreakMode = .byWordWrapping
        let attrs: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: COM_FONT_SIZE)
        ]
        let attrStr = dataSourceFiltered[indexPath.row].com?.htmlToAttributedString(attrs: attrs)
        comment.attributedText = attrStr
        comment.frame = CGRect(x: x, y: 8, width: tableView.frame.width - (x + 20), height: CGFloat.greatestFiniteMagnitude)
        comment.sizeToFit()
        comment.frame = CGRect(x: comment.frame.origin.x, y: 24, width: comment.frame.width, height: comment.frame.height)
        
        cell.contentView.addSubview(comment)
        
        if highlightCellIndex == indexPath.row {
            let defaultColor = cell.backgroundColor
            cell.backgroundColor = .yellow
            UIView.animateKeyframes(withDuration: 1, delay: 1, options: [], animations: {
                cell.backgroundColor = defaultColor
            }, completion: { _ in
                self.highlightCellIndex = nil
            })
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = dataSource.firstIndex(where: { $0.no == dataSourceFiltered[indexPath.row].no })!
        let indexPathToFind = IndexPath(item: index, section: 0)
        
        if searchController.isActive {
            searchController.isActive = false
            dataSourceFiltered = dataSource
            tableView.reloadData()
            tableView.layoutIfNeeded()
            tableView.scrollToRow(at: indexPathToFind, at: .middle, animated: false)
            highlightCellIndex = index
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var x = CGFloat(20)
        
        if dataSourceFiltered.count == 0 {
            return 0
        }
        
        if dataSourceFiltered[indexPath.row].filename != nil {
            x = CGFloat(128)
        }
        let comment = UILabel()
        comment.font = comment.font.withSize(COM_FONT_SIZE)
        comment.numberOfLines = 0
        comment.lineBreakMode = .byWordWrapping
        let attrs: [NSAttributedString.Key : Any] = [
            .font : UIFont.systemFont(ofSize: COM_FONT_SIZE)
        ]
        let attrStr = dataSourceFiltered[indexPath.row].com?.htmlToAttributedString(attrs: attrs)
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
