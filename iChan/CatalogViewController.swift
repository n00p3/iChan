//
//  CatalogViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import Cards

class CatalogViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    let refreshControl = UIRefreshControl()
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    var catalog: Catalog = []
    
    override func viewDidLoad() {
        // fix weird scroll:  https://stackoverflow.com/questions/50708081/prefer-large-titles-and-refreshcontrol-not-working-well
        
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshRequested(_:)), for: .valueChanged)
        
        let top = self.collectionView.adjustedContentInset.top
        let y = self.refreshControl.frame.maxY + top
        self.collectionView.setContentOffset(CGPoint(x: 0, y: -y), animated:true)
        self.extendedLayoutIncludesOpaqueBars = true
        collectionView.refreshControl = refreshControl
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let boardsButton = UIBarButtonItem(title: "Boards", style: .plain, target: self, action: #selector(openBoardsModal))
        navigationItem.rightBarButtonItem = boardsButton
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        Requests.catalog(of: "int", success: { (catalog: Catalog) in
            self.catalog = catalog
            activityIndicator.stopAnimating()
            
            self.collectionView.reloadData()
            NSLog("\(catalog.count) pages")
        }) { (error) in
            NSLog("Failed to load catalog; \(error.localizedDescription)")
        }
        
    }
    
    @objc private func openBoardsModal() {
        let popup = self.storyboard?.instantiateViewController(withIdentifier: "BoardsModalViewController") as! UINavigationController
        present(popup, animated: true)
    }
    

    @objc private func refreshRequested(_ sender: AnyObject) {
        print("refresh requested")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
}

extension CatalogViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return catalog.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        catalog[section].threads.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ThreadCatalogCell", for: indexPath) as! ThreadCatalogCell
        
        let card = CardHighlight(frame: CGRect(x: 10, y: 30, width: 100 , height: 120))
        
        card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        card.title = catalog[indexPath.section].threads[indexPath.row].sub ?? ""
        card.titleSize = 12
        card.itemTitle = ""
        card.itemSubtitle = catalog[indexPath.section].threads[indexPath.row].com ?? ""
        card.textColor = UIColor.white
        card.buttonText = nil
        card.shadowOpacity = 0
        
        card.hasParallax = true
        
        card.center = CGPoint(x: cell.frame.size.width / 2,
                              y: cell.frame.size.height / 2)
        
        
        let ext = catalog[indexPath.section].threads[indexPath.row].ext ?? ""
        let tim = catalog[indexPath.section].threads[indexPath.row].tim ?? 0
        
        cell.view.addSubview(card)
        
        return cell
    }
    
    
}

extension CatalogViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "ThreadCatalogHeader",
                    for: indexPath) as? ThreadCatalogHeader
                else {
                    fatalError("Invalid view type")
            }
            
            headerView.headerPage.text = "Page \(indexPath.section + 1)"
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
}
