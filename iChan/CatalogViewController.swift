//
//  CatalogViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit


class CatalogViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
        left: 20.0,
        bottom: 50.0,
        right: 20.0)
        
    var catalog: Catalog = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.prompt = "g - Technology"
        
        let boardsButton = UIBarButtonItem(title: "Boards", style: .plain, target: self, action: #selector(openBoardsModal))
        navigationItem.rightBarButtonItem = boardsButton
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        Requests.catalog(of: "int", success: { (catalog: Catalog) in
            self.catalog = catalog

            self.collectionView.reloadData()
            NSLog("\(catalog.count) pages")
        }) { (error) in
            NSLog("Failed to load catalog; \(error.localizedDescription)")
        }
        
    }
    
    @objc private func openBoardsModal() {
        //let boardsVC = BoardsModalViewController()
        //boardsVC.modalPresentationStyle = .pageSheet
        //present(boardsVC, animated: true)
        let popup = self.storyboard?.instantiateViewController(withIdentifier: "BoardsModalViewController") as! UINavigationController
        present(popup, animated: true)
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let backButton = UIBarButtonItem()
//        backButton.title = "Boards"
//        navigationController?.navigationItem.backBarButtonItem = backButton
//    }

}

extension CatalogViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
      return catalog.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        catalog[section].threads.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return catalog[0].threads[indexPath.row].sub
        let cell = collectionView
          .dequeueReusableCell(withReuseIdentifier: "ThreadCatalogCell", for: indexPath) as! ThreadCatalogCell
        cell.backgroundColor = .lightGray
    
        // Configure the cell
        
        cell.content.text = catalog[indexPath.section].threads[indexPath.row].com

        cell.content.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
        
        
        let ext = catalog[indexPath.section].threads[indexPath.row].ext ?? ""
        let tim = catalog[indexPath.section].threads[indexPath.row].tim ?? 0
        
        Requests.image("int", tim, ext) { (img) in
            cell.image.image = img
        }
        
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
//    print("per item: \(widthPerItem)")
    
    return CGSize(width: widthPerItem, height: widthPerItem)
  }
  
  //3
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }
  
  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
