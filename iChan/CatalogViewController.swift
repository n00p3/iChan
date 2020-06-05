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

class CatalogViewController: UIViewController, CatalogBoardDelegate {
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
            print("Reading catalog from api")
            self.storeCatalogInRealm(board: board, liveCatalog: catalog)
            
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
    
    func boardChanged(newBoard: String) {
        print("new board \(newBoard)")
    }
    
    @objc private func refreshRequested(_ sender: AnyObject) {
        print("refresh requested")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.refreshControl.endRefreshing()
//        }
        
        Requests.catalog(of: currentBoard, success: { (catalog: Catalog) in
            print("Reading catalog from api")
            self.storeCatalogInRealm(board: self.currentBoard, liveCatalog: catalog)
            
            self.getCatalog(board: self.currentBoard, callback: { catalog in
                self.catalog = catalog!
            })
            
            NSLog("\(catalog.count) pages")
        }) { (error) in
            NSLog("Failed to load catalog; \(error.localizedDescription)")
        }
    }

    /**
     Saves catalog in local memory for faster access. Removes previously stored catalog for specific board.
     - Parameter board: Board name.
     - Parameter liveCatalog: Catalog freshly fetched from 4chan API.
     */
    private func storeCatalogInRealm(board: String, liveCatalog: Catalog) {
        print("Storing catalog in realm.")
        let realm = try! Realm()
        let oldCatalogs = realm.objects(CatalogThreadRealm.self).filter("board = \"\(board)\"")
        try! realm.write {
            realm.delete(oldCatalogs)

            for element in liveCatalog {
                element.threads.forEach {
                    let newCatalogThread = CatalogThreadRealm()
                    newCatalogThread.board = board
                    newCatalogThread.sub = $0.sub ?? ""
                    newCatalogThread.com = $0.com ?? ""
                    newCatalogThread.no = $0.no
                    newCatalogThread.lastAccessed = Date()
                    newCatalogThread.page = element.page
                    newCatalogThread.image = nil

                    realm.add(newCatalogThread)
                }
            }
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
            callback(UIImage(data: storedThread.first!.image!))
            return
        }
        
        let ext = storedThread.first?.ext ?? ""
        Requests.image(board, threadNo, ext, fullSize: false) { (img) in
//            card.backgroundImage = img
            callback(img)
        }
        
    }

    /**
     Reads locally stored catalog for specific board.
     - Parameter board: Board name.
     */
    private func readCatalogFromRealm(board: String) -> Catalog? {
        let realm = try! Realm()
        let catalogs = realm.objects(CatalogThreadRealm.self)
            .filter("board == '\(board)'")

        if catalogs.count == 0 {
            return nil
        }

        // Pages starts from 1.
        let maxPages = catalogs.map { $0.page }.max() ?? 1


        var catalogElements = [CatalogElement]()
        for page in 1...maxPages {

            let threadsAtPage = catalogs.filter { $0.page == page }

            var threads = [CatalogThread]()
            threadsAtPage.forEach {
                let thread = CatalogThread(no: $0.no, sticky: $0.sticky, closed: $0.closed, now: String($0.closed), name: $0.name, sub: $0.sub, com: $0.com, filename: $0.filename, ext: $0.ext, w: nil, h: nil, tnW: nil, tnH: nil, tim: nil, time: nil, md5: nil, fsize: nil, resto: nil, capcode: nil, semanticURL: nil, replies: nil, images: nil, omittedPosts: nil, omittedImages: nil, lastReplies: nil, lastModified: nil, bumplimit: nil, imagelimit: nil, trip: nil)

                threads.append(thread)
            }
            let catalogElement = CatalogElement(page: page, threads: threads)
            catalogElements.append(catalogElement)
        }

        return catalogElements
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
        
        let no = catalog[indexPath.section].threads[indexPath.row].no
        readImageForThread(board: currentBoard, threadNo: no, callback: { img in
            card.backgroundImage = img
        })
        
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
