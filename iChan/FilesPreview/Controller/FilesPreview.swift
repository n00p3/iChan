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
    private var scrolls = [UIScrollView]()
//    private var currentVC: UIViewController?
    private var pager: UILabel?
    private var currentPage = 0
//    private var i = 0
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if let vc = viewControllers?.first as? ImagePreviewViewController {
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
        let i = vcs.firstIndex(of: pageViewController.viewControllers!.first!)
        currentPage = i ?? 0
        if finished && completed {
            let i = vcs.firstIndex(of: pageViewController.viewControllers!.first!)
            updatePager(currentPage: i ?? -1)
        }
        
        // Pause all videos,
        for it in vcs {
            if let v = it as? VideoPlayerController {
                v.pause()
            }
        }
        // except the current one.
        if let v = vcs[i!] as? VideoPlayerController {
            v.play()
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
            if url.absoluteString.hasSuffix(".webm") {
                vcs.append(videoVC(url: url))
            } else {
                vcs.append(imageVC(url: url))
            }
        }
        
        let blur = UIBlurEffect(style: .dark)
        let effect = UIVisualEffectView(effect: blur)
        effect.frame = view.bounds
        
        view.insertSubview(effect, at: 0)
        updatePager(currentPage: 0)
        
        setViewControllers([vcs.first!], direction: .forward, animated: true, completion: nil)
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
    
    private func videoVC(url: URL) -> VideoPlayerController {
        let vc = UIStoryboard(name: "VideoPlayer", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerController") as! VideoPlayerController
        vc.videoURL = url.absoluteString
        return vc
    }
    
    private func imageVC(url: URL) -> ImagePreviewViewController {
        let vc = ImagePreviewViewController()
        
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
        
        scrolls.append(scroll)
        
        vc.imgView = img
        vc.scrollView = scroll
        
        return vc
    }
    
    @objc private func doubleTapped(_ sender: UITapGestureRecognizer) {
        let scroll = scrolls[currentPage]
        if scroll.zoomScale == 1.0 {
            scroll.setZoomScale(2.0, animated: true)
        } else {
            scroll.setZoomScale(1.0, animated: true)
        }
    }
}
