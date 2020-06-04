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

class BookmarksViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = [BookmarkElement]()
    
    override func viewDidLoad() {
        navigationController?.navigationBar.prefersLargeTitles = true
        super.viewDidLoad()
        
        dataSource.append(
            BookmarkElement(board: "int", threadNo: 23, title: "thread 1", newRepliesCnt: 0)
        )
        
        dataSource.append(
            BookmarkElement(board: "int", threadNo: 123, title: "thread 2", newRepliesCnt: 3)
        )
        
        tableView.dataSource = self
    }
    
    func generateCard() -> UIView {
        // Aspect Ratio of 5:6 is preferred
        let card = CardHighlight(frame: CGRect(x: 10, y: 30, width: 100 , height: 120))
        
        card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        //        card.icon = UIImage(named: "flappy")
        card.title = "Welcome \nto \nCards !"
        card.itemTitle = "Flappy Bird"
        card.itemSubtitle = "Flap That !"
        card.textColor = UIColor.white
        
        card.hasParallax = true
        
        let cardContentVC = storyboard!.instantiateViewController(withIdentifier: "CardContent")
        card.shouldPresent(cardContentVC, from: self, fullscreen: false)
        
        return card
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.dataSource.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
            if self.dataSource[indexPath.item].newRepliesCnt == 0 {
                return ""
            } else {
                return "(+\(self.dataSource[indexPath.item].newRepliesCnt))"
            }
        }()
        
        let label = "\(board) - \(title) \(newRepliesCnt)"
        
        cell.textLabel?.text = label
        return cell
    }
    
    
}
