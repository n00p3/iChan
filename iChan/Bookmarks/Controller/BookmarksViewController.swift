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
import Player
import MobileVLCKit
import AVKit

class BookmarksViewController: UIViewController, VLCMediaPlayerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var buttonRemoveAllBookmarks: UIBarButtonItem?
    var player: VLCMediaPlayer?
    var dataSource: [BookmarkElement] = [BookmarkElement]() {
        didSet {
            updateDeletionButton()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        fetchBookmarks()
        
        // Preload thread view.
        tabBarController?.viewControllers?[2].loadViewIfNeeded()
//        tabBarController?.viewControllers?.forEach { let _ = $0.view }
        DataHolder.shared.threadChangedEvent.emit(DataHolder.shared.currentThread)
    }
    
    private func fetchBookmarks() {
        let realm = try! Realm()
        let bookmarks = try! realm.objects(BookmarkRealm.self)
        
        dataSource.removeAll()
        
        for bookmark in bookmarks {
            let element = BookmarkElement(board: bookmark.board, threadNo: bookmark.threadNo, title: bookmark.title, repliesCnt: 0)
            dataSource.append(element)
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        let realm = try! Realm()
        for i in (0..<self.dataSource.count).reversed() {
            try! realm.write {
                let bookmark = realm.objects(BookmarkRealm.self).filter(NSPredicate(format: "threadNo = %d", self.dataSource[i].threadNo))
                realm.delete(bookmark)
            }
            self.dataSource.remove(at: i)
            self.tableView.deleteRows(at: [IndexPath(item: i, section: 0)], with: .automatic)
        }
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        if player?.state == .stopped {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidLoad()
        
        buttonRemoveAllBookmarks = UIBarButtonItem(title: "Delete all", style: .plain, target: self, action: #selector(deleteAllBookmarksClicked(_:)))
        navigationItem.rightBarButtonItem = buttonRemoveAllBookmarks
        
        tableView.dataSource = self
        
        fetchBookmarks()
        
//        let url = URL(string: "https://i.4cdn.org/wsg/1595758660757.webm")
////        let url = URL(string: "https://i.4cdn.org/wsg/1594028421375.webm")
//        let url = URL(string: "http://dl5.webmfiles.org/big-buck-bunny_trailer.webm")
////        let url = URL(string: "https://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4")
//
//        player = VLCMediaPlayer()
//        player?.delegate = self
////        player?.drawable = view
//        player?.media = VLCMedia(url: url!)
//        player
//
//
//        present(controller, animated: true)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//            self.player?.play()
//        })
        

        let vc = UIStoryboard(name: "VideoPlayer", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerController")
        present(vc, animated: true)
        
        
//        let player = Player()
////        player.playerDelegate = self
////        player.playbackDelegate = self
//        player.view.frame = view.frame
//        player.fillMode = PlayerFillMode.resizeAspect
//        player.url = url
//        player.playFromBeginning()
//
//        present(player, animated: true)
//        self.player = Player()
//        self.player.playerDelegate = self
//        self.player.playbackDelegate = self
//        self.player.view.frame = self.view.frame
//
//        print("player: \(self.player.view.frame)")
//
//        self.addChild(self.player)
//        self.view.addSubview(self.player.view)
//        self.player.didMove(toParent: self)
//        self.player.playbackLoops = true
//
//
//        self.player.url = url
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let realm = try! Realm()
            try! realm.write {
                let bookmark = realm.objects(BookmarkRealm.self).filter(NSPredicate(format: "threadNo = %d", self.dataSource[indexPath.row].threadNo))
                realm.delete(bookmark)
            }
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
            if self.dataSource[indexPath.item].repliesCnt == 0 {
                return ""
            } else {
                return "(+\(self.dataSource[indexPath.item].repliesCnt))"
            }
        }()
        
        let label = "\(board) - \(title) \(newRepliesCnt)"
        
        cell.textLabel?.text = label
        return cell
    }
    
    
}
