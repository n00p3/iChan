//
//  CatalogViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import RealmSwift
import SPAlert
import EmitterKit
import Lightbox

protocol CatalogBoardDelegate {
    func boardChanged(newBoard: String)
}

class CatalogViewController: UIViewController, CatalogBoardDelegate, UISearchResultsUpdating {
    private let CATALOG_FONT_SIZE = CGFloat(10)
    private var search = ""
    
    func updateSearchResults(for searchController: UISearchController) {
        search = searchController.searchBar.text ?? ""
        
        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
             self.updateSearchDebounced()
        }
    }
    
    private func updateSearchDebounced() {
        catalogFiltered = Catalog(catalog)
        
        if search.count == 0 {
            self.collectionView.reloadData()
            return
        }
        
        for pageId in (0..<catalogFiltered.count).reversed() {
            for threadId in (0..<catalogFiltered[pageId].threads.count).reversed() {
                if !((catalogFiltered[pageId].threads[threadId].sub?.lowercased().contains(search.lowercased()))! ||
                    (catalogFiltered[pageId].threads[threadId].com?.lowercased().contains(search.lowercased()))!) {
                    catalogFiltered[pageId].threads.remove(at: threadId)
                }
            }
        }
        
        self.collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    let blur = UIBlurEffect(style: .regular)
    let refreshControl = UIRefreshControl()
    var activityIndicator: UIActivityIndicatorView?
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 0,
                                             left: 20.0,
                                             bottom: 0,
                                             right: 20.0)
    
    var catalog: Catalog = []
    var catalogFiltered: Catalog = []
    
    override func viewDidLoad() {
        // fix weird scroll:  https://stackoverflow.com/questions/50708081/prefer-large-titles-and-refreshcontrol-not-working-well
        
        super.viewDidLoad()
        
        let realmBoard = try! Realm().objects(Settings.self).first?.currentBoardInCatalog
        if realmBoard!.isEmpty {
            DataHolder.shared.currentCatalogBoard = "g"
        } else {
            DataHolder.shared.currentCatalogBoard = realmBoard!
        }
        
        updateHeader()

        navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationController?.navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refreshRequested(_:)), for: .valueChanged)
        
        let top = self.collectionView.adjustedContentInset.top
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
        
        getCatalog(board: DataHolder.shared.currentCatalogBoard, callback: { catalog in
            if catalog != nil {
                
                self.catalogFiltered = catalog!
                self.catalog = catalog!
                self.activityIndicator!.stopAnimating()
                
                self.collectionView.reloadData()
            }
        })
        
        collectionView.register(ThreadCatalogCell.self, forCellWithReuseIdentifier: "ThreadCatalogCell")
    }
    
    private func addToBookmarks(threadNo: Int, board: String, title: String) {
        let realm = try! Realm()
        try! realm.write {
            let bookmark = BookmarkRealm()
            bookmark.repliesCnt = 0
            bookmark.board = board
            bookmark.threadNo = threadNo
            bookmark.title = title
            
            realm.add(bookmark)
        }
        
        SPAlert.present(message: "Bookmark added!")
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
        let fullName = try! Realm().objects(BoardsRealm.self).first?.boards.filter { $0.board == DataHolder.shared.currentCatalogBoard }.first
        if fullName != nil {
            navigationItem.title = fullName!.board + " - " + fullName!.title
        }
    }
    
    func boardChanged(newBoard: String) {
        print("new board \(newBoard)")
        DataHolder.shared.currentCatalogBoard = newBoard
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
        
        Requests.catalog(of: DataHolder.shared.currentCatalogBoard, success: { (catalog: Catalog) in
            storeCatalogInRealm(board: DataHolder.shared.currentCatalogBoard, liveCatalog: catalog)
            
            self.getCatalog(board: DataHolder.shared.currentCatalogBoard, callback: { catalog in
                DispatchQueue.main.async {
                    self.catalogFiltered = catalog!
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
        
        let x = self.catalogFiltered.map { $0.threads }.joined().filter { $0.no == threadNo }.first
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
    
    private func store(thread: CatalogThread) {
        let realm = try! Realm()
        try! realm.write {
            let realmThread = CatalogThreadRealm()
            realmThread.board =  DataHolder.shared.currentCatalogBoard
            realmThread.no =  thread.no
            realmThread.sticky =  thread.sticky ?? 0
            realmThread.closed =  thread.closed ?? 0
            realmThread.now =  thread.now ?? ""
            realmThread.name =  thread.name ?? ""
            realmThread.sub =  thread.sub ?? ""
            realmThread.com =  thread.com ?? ""
            realmThread.filename =  thread.filename ?? ""
            realmThread.ext =  thread.ext ?? ""
            realmThread.lastAccessed =  Date()
            // TODO: implement later.
            realmThread.tim = -1
            realmThread.page = -1
        }
    }
}

extension CatalogViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return catalogFiltered.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return catalogFiltered[section].threads.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let realm = try! Realm()
        let thread = realm.objects(BookmarkRealm.self)
            .filter(NSPredicate(format: "threadNo = %d", catalogFiltered[indexPath.section].threads[indexPath.row].no)).first
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ _ in
            var bookmark: UIAction
            if thread == nil {
                bookmark = UIAction(title: "Add to bookmarks", image: UIImage(systemName: "star"), identifier: UIAction.Identifier(rawValue: "bookmark")) { menu in
                    let thread = self.catalogFiltered[indexPath.section].threads[indexPath.row]
                    let subject = [thread.sub ?? "", thread.com ?? "", "[no comment]"].filter { $0 != "" }.first!
                    
                    self.addToBookmarks(threadNo: thread.no, board: DataHolder.shared.currentCatalogBoard, title: subject)
                }
            } else {
                bookmark = UIAction(title: "Remove from bookmarks", image: UIImage(systemName: "star.slash"), identifier: UIAction.Identifier(rawValue: "bookmark")) { menu in
                    try! realm.write { realm.delete(thread!) }
                    SPAlert.present(message: "Bookmark removed!")
                }
            }
            let hide = UIAction(title: "Hide thread", image: UIImage(systemName: "eye.slash"), identifier: UIAction.Identifier(rawValue: "hide")) { action in
                print("Hide clicked.")
            }
            
            
            let thread = self.catalogFiltered[indexPath.section].threads[indexPath.row]
           
            let viewFile = UIAction(title: "View OP file", image: UIImage(systemName: "eye"), identifier: UIAction.Identifier(rawValue: "viewImage")) { action in
                self.viewOpFile(thread: thread)
            }
            
            let children = [bookmark, hide, viewFile]
            return UIMenu(title: "Options", image: nil, identifier: nil, children: children)
        }
        
        return configuration
    }
    
    private func viewOpFile(thread: CatalogThread) {
        filePreviewHandler(parent: self, board: DataHolder.shared.currentCatalogBoard, tim: thread.tim ?? 0, ext: thread.ext ?? "")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let H = CGFloat(35)
        
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "ThreadCatalogCell", for: indexPath)
        for subView in cell.contentView.subviews {
            subView.removeFromSuperview()
        }
        
        let no = catalogFiltered[indexPath.section].threads[indexPath.row].no

        store(thread: self.catalogFiltered[indexPath.section].threads[indexPath.row])
        readImageForThread(board: DataHolder.shared.currentCatalogBoard, threadNo: no, callback: { img in
            if img != nil {
                let i = UIImageView(image: img!)
                i.frame = CGRect(x: i.frame.origin.x, y: i.frame.origin.y, width: cell.frame.width, height: cell.frame.height)
                i.contentMode = .scaleAspectFill
                cell.contentView.addSubview(i)
            }
            
            
            let effect = UIVisualEffectView(effect: self.blur)
            
            effect.frame = CGRect(
                x: cell.contentView.frame.origin.x,
                y: (cell.contentView.frame.height - H) + cell.contentView.frame.origin.y,
                width: cell.contentView.frame.width,
                height: H)
            
            cell.contentView.addSubview(effect)
            
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.clipsToBounds = true
            
            
            if indexPath.row >= self.catalogFiltered[indexPath.section].threads.count {
                return
            }
            let sub = self.catalogFiltered[indexPath.section].threads[indexPath.row].sub ?? ""
            let com = self.catalogFiltered[indexPath.section].threads[indexPath.row].com ?? ""
            
            let title = [sub, com].filter { $0 != "" }.first ?? "[no comment]"
            
            let label = UILabel()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2

            let attrs: [NSAttributedString.Key : Any] = [
                .font : UIFont.systemFont(ofSize: self.CATALOG_FONT_SIZE),
                .paragraphStyle : paragraphStyle
            ]
            label.adjustsFontSizeToFitWidth = true
            label.attributedText = title.htmlToAttributedString(attrs: attrs)
            label.minimumScaleFactor = 0.5
            label.lineBreakMode = .byWordWrapping
            label.numberOfLines = 2
            
            let INSET = CGFloat(8)
            label.frame = CGRect(
                x: cell.contentView.frame.origin.x + INSET,
                y: ((cell.contentView.frame.height - H) + cell.contentView.frame.origin.y) + INSET / 2,
                width: cell.contentView.frame.width - INSET * 2,
                height: H * 0.8)
            label.sizeToFit()
            cell.contentView.addSubview(label)
        })
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DataHolder.shared.currentThread = CurrentThread(
            threadNo: catalogFiltered[indexPath.section].threads[indexPath.row].no,
            board: DataHolder.shared.currentCatalogBoard)
        
        let thread = catalogFiltered[indexPath.section].threads[indexPath.row]
        
        DataHolder.shared.threadChangedEvent.emit(CurrentThread(threadNo: thread.no, board: DataHolder.shared.currentCatalogBoard))
        tabBarController?.selectedIndex = 2
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if catalogFiltered.count == 0 {
            return CGSize.zero
        }
        
        if self.catalogFiltered[section].threads.count == 0 {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.width, height: 50)
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
            headerView.headerPage.textColor = .gray
            headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: headerView.frame.height)
            return headerView
        default:
            assert(false, "Invalid element type")
        }
    }
}
