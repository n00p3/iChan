//
//  CatalogViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import Cards
import RealmSwift

protocol CatalogBoardDelegate {
    func boardChanged(newBoard: String)
}

class CatalogViewController: UIViewController, CatalogBoardDelegate, UIContextMenuInteractionDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentBoard = ""
    
    let refreshControl = UIRefreshControl()
    var activityIndicator: UIActivityIndicatorView?
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    
    var catalog: Catalog = []
    
    override func viewDidLoad() {
        // fix weird scroll:  https://stackoverflow.com/questions/50708081/prefer-large-titles-and-refreshcontrol-not-working-well
        
        super.viewDidLoad()
        
        currentBoard = try! Realm().objects(Settings.self).first?.currentBoard ?? "a"
        
        updateHeader()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshRequested(_:)), for: .valueChanged)
        
        let top = self.collectionView.adjustedContentInset.top
        let y = self.refreshControl.frame.maxY + top
//        self.collectionView.setContentOffset(CGPoint(x: 0, y: -y), animated:true)
        self.extendedLayoutIncludesOpaqueBars = true
        collectionView.refreshControl = refreshControl
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator!.center = view.center
        view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
        
        let boardsButton = UIBarButtonItem(title: "Boards", style: .plain, target: self, action: #selector(openBoardsModal))
        navigationItem.rightBarButtonItem = boardsButton
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        getCatalog(board: currentBoard, callback: { catalog in
            if catalog != nil {
                
                self.catalog = catalog!
                self.activityIndicator!.stopAnimating()
                
                self.collectionView.reloadData()
            }
        })
        
        collectionView.register(ThreadCatalogCell.self, forCellWithReuseIdentifier: "ThreadCatalogCell")
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ action in
            let bookmark = UIAction(title: "Add to bookmarks", image: UIImage(systemName: "star"), identifier: UIAction.Identifier(rawValue: "bookmark")) { _ in
                print("Add to bookmarks clicked,")
            }
            let hide = UIAction(title: "Hide thread", image: UIImage(systemName: "eye.slash"), identifier: UIAction.Identifier(rawValue: "hide")) { action in
                print("Hide clicked.")
            }
            let viewImage = UIAction(title: "View OP file", image: UIImage(systemName: "eye"), identifier: UIAction.Identifier(rawValue: "viewImage")) { action in
                print("View image clicked.")
            }
            
            return UIMenu(title: "Options", image: nil, identifier: nil, children: [bookmark, hide, viewImage])
        }
        
        return configuration
    }
    
    /**
     Gets locally stored catalog. If not present then fetches from api and caches.
     */
    private func getCatalog(board: String, callback: @escaping (Catalog?) -> ()) {
        let catalog = readCatalogFromRealm(board: board)
        if catalog != nil {
            print("Reading catalog from realm")
            callback(catalog)
            return
        }
        
        Requests.catalog(of: board, success: { (catalog: Catalog) in
            storeCatalogInRealm(board: board, liveCatalog: catalog)
            
            NSLog("\(catalog.count) pages")
        }) { (error) in
            NSLog("Failed to load catalog; \(error.localizedDescription)")
        }
    }
    
    @objc private func openBoardsModal() {
        let popup = self.storyboard?.instantiateViewController(withIdentifier: "BoardsModalViewController") as! BoardsModalViewController //UINavigationController
        let navigationController = UINavigationController(rootViewController: popup)
        popup.myDelegate = self
//        popup.modalPresentationStyle = .pageSheet
//        navigationController?.pushViewController(popup, animated: true)
//        navigationController?.show(popup, sender: self)
//        popup.delegate = self
        present(navigationController, animated: true)
    }
    
    func updateHeader() {
        let fullName = try! Realm().objects(BoardsRealm.self).first?.boards.filter { $0.board == self.currentBoard }.first
        if fullName != nil {
            navigationItem.title = fullName!.board + " - " + fullName!.title
        }
    }
    
    func boardChanged(newBoard: String) {
        print("new board \(newBoard)")
        currentBoard = newBoard
        let x: AnyObject = "" as AnyObject
        refreshRequested(x)
        updateHeader()
    }
    
    @objc private func refreshRequested(_ sender: AnyObject) {
        print("refresh requested")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.refreshControl.endRefreshing()
//        }
        collectionView.alpha = 0
        activityIndicator?.startAnimating()
        
        Requests.catalog(of: currentBoard, success: { (catalog: Catalog) in
            storeCatalogInRealm(board: self.currentBoard, liveCatalog: catalog)
            
            self.getCatalog(board: self.currentBoard, callback: { catalog in
                DispatchQueue.main.async {
                    self.catalog = catalog!
                
            
                    self.refreshControl.endRefreshing()
                    self.activityIndicator?.stopAnimating()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.collectionView.alpha = 1
                        })
                    })
                    self.collectionView.reloadData()
                }
            

            })
            
            NSLog("\(catalog.count) pages")
        }) { (error) in
            NSLog("Failed to load catalog; \(error.localizedDescription)")
        }
    }

    /**
     Writes image for specific thread number and board.
     */
    private func storeImageForThread(board: String, threadNo: Int, data: Data) {
        let realm = try! Realm()

        try! realm.write {
            // Add image to stored thread if exists.
            // Has to escape 'no' using hash.
            let filter = "board = \"\(board)\" AND #no = \(threadNo)"
            let storedThread = realm.objects(CatalogThreadRealm.self)
                .filter(filter)

            for thread in storedThread {
                thread.image = data
            }
        }
        
        let r2 = try! Realm()
        let filter = "board = \"\(board)\" AND #no = \(threadNo)"
        _ = r2.objects(CatalogThreadRealm.self).filter(filter)
        
    }

    /**
     Reads image for specific thread number and board if given image exists.
     */
    private func readImageForThread(board: String, threadNo: Int, callback: @escaping (UIImage?) -> ()) {
        let realm = try! Realm()
        let filter = "board == \"\(board)\" AND #no == \(threadNo)"
        let storedThread = realm.objects(CatalogThreadRealm.self)
            .filter(filter)

        if storedThread.first?.image != nil {
//            print("local \(threadNo)")
            callback(UIImage(data: storedThread.first!.image!))
            return
        }
//        print("remote \(threadNo)")
        
        let x = self.catalog.map { $0.threads }.joined().filter { $0.no == threadNo }.first
        let ext = x?.ext ?? ""
        let tim = x?.tim ?? 0
        Requests.image(board, tim, ext, fullSize: false) { (img) in
//            card.backgroundImage = img
            if img?.pngData() != nil {
                self.storeImageForThread(board: board, threadNo: threadNo, data: img!.pngData()!)
            }
            callback(img)
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
        let H = CGFloat(35)
        
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ThreadCatalogCell", for: indexPath)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        
        let no = catalog[indexPath.section].threads[indexPath.row].no

        readImageForThread(board: currentBoard, threadNo: no, callback: { img in
            if img != nil {
                let i = UIImageView(image: img!)
                i.frame = CGRect(x: i.frame.origin.x, y: i.frame.origin.y, width: cell.frame.width, height: cell.frame.height)
                i.contentMode = .scaleAspectFill
                cell.contentView.addSubview(i)
            }
            
            let blur = UIBlurEffect(style: .regular)
            let effect = UIVisualEffectView(effect: blur)
            
            effect.frame = CGRect(
                x: cell.contentView.frame.origin.x,
                y: (cell.contentView.frame.height - H) + cell.contentView.frame.origin.y,
                width: cell.contentView.frame.width,
                height: H)
            
            cell.contentView.addSubview(effect)
            
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.clipsToBounds = true
            
            let sub = self.catalog[indexPath.section].threads[indexPath.row].sub ?? ""
            let com = self.catalog[indexPath.section].threads[indexPath.row].com ?? ""
            
            let title = [sub, com].filter { $0 != "" }.first ?? "[no comment]"
            
            let label = UILabel()
            label.text = title
            label.minimumScaleFactor = 0.5
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 2
            
            let INSET = CGFloat(8)
            label.frame = CGRect(
                x: cell.contentView.frame.origin.x + INSET,
                y: ((cell.contentView.frame.height - H) + cell.contentView.frame.origin.y) + INSET / 2,
                width: cell.contentView.frame.width - INSET * 2,
                height: H * 0.8)
            cell.contentView.addSubview(label)
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(catalog[indexPath.section].threads[indexPath.row])
        DataHolder.shared.threadNo = catalog[indexPath.section].threads[indexPath.row].no
        DataHolder.shared.threadBoard = currentBoard
        
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
            headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y + 8, width: headerView.frame.width, height: headerView.frame.height)
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
}
