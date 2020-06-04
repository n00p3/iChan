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

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        view.addSubview(card)
        
        collectionView.dataSource = self
        
        for _ in 0...10 {
            self.dataSource.append(generateCard())
        }
        
        
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
}

extension BookmarksViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
    }
    
    
}

