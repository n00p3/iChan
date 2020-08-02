//
//  FilesPreview.swift
//  iChan
//
//  Created by Mateusz Głowski on 02/08/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import UIKit
import SDWebImage
import SPAlert
import Kingfisher

class FilesPreview : UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    var urls = [URL]()
    private var vcs = [UIViewController]()
//    private var currentImage: UIImageView?
//    private var currentScroll: UIScrollView?
//    private var currentVC: UIViewController?
    private var pager: UILabel?
//    private var i = 0
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if let vc = viewControllers?.first as? FilesPreviewViewController {
            return vc.imgView
        }
        
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vcs.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard vcs.count > previousIndex else {
            return nil
        }

        return vcs[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vcs.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = vcs.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return vcs[nextIndex]
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished && completed {
            let i = vcs.firstIndex(of: pageViewController.viewControllers!.first!)
            updatePager(currentPage: i ?? -1)
        }
    }
    
    
    init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [NSObject : AnyObject]!) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options as? [UIPageViewController.OptionsKey : Any])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        for url in urls {
            vcs.append(imageVC(url: url))
        }
        
        let blur = UIBlurEffect(style: .dark)
        let effect = UIVisualEffectView(effect: blur)
        effect.frame = view.bounds
        
        view.insertSubview(effect, at: 0)
        updatePager(currentPage: 0)
        
        setViewControllers([vcs.first!], direction: .forward, animated: true, completion: nil)
        

        let moreButton = UIButton()
        moreButton.setTitle("More", for: .normal)
//        moreButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        moreButton.sizeToFit()
        moreButton.backgroundColor = .green
        
//        moreButton.translatesAutoresizingMaskIntoConstraints = true
//        view.addSubview(moreButton)
////        view.addConstraints([horizontalConstraint, verticalConstraint])
//        let margins = view.layoutMarginsGuide
//        NSLayoutConstraint.activate([
//            moreButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
//            moreButton.leadingAnchor.constraint(equalTo: margins.trailingAnchor)
//        ])
//
//        let guide = view.safeAreaLayoutGuide
//        NSLayoutConstraint.activate([
//            moreButton.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
//            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: moreButton.bottomAnchor, multiplier: 1.0)
//         ])
    }
    
    private func updatePager(currentPage: Int) {
        if pager == nil {
            pager = UILabel()
            view.addSubview(pager!)
            pager?.textColor = .white
        }

        pager?.text = "\(mod(currentPage, vcs.count) + 1)/\(vcs.count)"
        pager?.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: pager!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: pager!, attribute: NSLayoutConstraint.Attribute.bottomMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1, constant: -10)
        view.addConstraints([horizontalConstraint, verticalConstraint])
    }
    
    private func imageVC(url: URL) -> FilesPreviewViewController {
        let vc = FilesPreviewViewController()
        
//        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "test", style: .plain, target: self, action: nil)
        vc.modalPresentationStyle = .fullScreen
        
        let img = UIImageView()
        img.frame = view.bounds
        
        img.kf.setImage(with: url)
        img.contentMode = .scaleAspectFit
        
        let scroll = UIScrollView()
        scroll.frame = self.view.bounds
        scroll.isUserInteractionEnabled = true
        scroll.delegate = self
        scroll.addSubview(img)
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 10.0
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scroll.addGestureRecognizer(doubleTapGesture)
        vc.view.addSubview(scroll)
        vc.view.addSubview(scroll)
        
        vc.imgView = img
        vc.scrollView = scroll
        
        return vc
    }
    
    @objc private func doubleTapped(_ sender: UITapGestureRecognizer) {
//        if currentScroll?.zoomScale == 1.0 {
//            currentScroll?.setZoomScale(2.0, animated: true)
//        } else {
//            currentScroll?.setZoomScale(1.0, animated: true)
//        }
    }
}
