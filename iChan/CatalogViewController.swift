//
//  CatalogViewController.swift
//  iChan
//
//  Created by Mateusz Głowski on 19/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit


class CatalogViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.prompt = "g - Technology"
        
        let boardsButton = UIBarButtonItem(title: "Boards", style: .plain, target: self, action: #selector(openBoardsModal))
        navigationItem.rightBarButtonItem = boardsButton
        
        
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

