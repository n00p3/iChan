//
//  FilesPreviewNavigationController.swift
//  iChan
//
//  Created by Mateusz Głowski on 02/08/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit

class FilesPreviewNavigation : UINavigationController {
    var urls = [URL]()
//    var parent: UIViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let vc = FilesPreview(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.urls = urls
//        vc.modalPresentationStyle = .overFullScreen

        let navBar = UINavigationController(rootViewController: vc)
        navBar.view.addSubview(vc.view)
        navBar.view.layoutSubviews()
//        navBar.setViewControllers([vc], animated: true)
        navBar.modalPresentationStyle = .overFullScreen
        navBar.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(self.moreClicked(_:)))
//        navBar.viewControllers.append(vc)
//        navigationController?.pushViewController(vc, animated: true)
        present(navBar, animated: true)
    }
    
    @objc private func moreClicked(_ sender: AnyObject) {
        let sheet = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Download", style: .default, handler: nil))

        present(sheet, animated: true)
    }
    
}
