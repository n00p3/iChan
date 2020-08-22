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
import SafariServices
import Photos

class FilesPreview : UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    var urls = [Post]()
    var currentPage = 0
    private var vcs = [UIViewController]()
    private var scrolls = [UIScrollView]()
//    private var currentVC: UIViewController?
    private var pager: UILabel?
    private var moreButton: UIButton?
    
//    private var i = 0
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if let vc = viewControllers?.first as? ImagePreviewViewController {
            return vc.imgView
        }
        
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vcs.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard vcs.count > previousIndex else {
            return nil
        }
        
        vcs[previousIndex] = createControllerFor(page: previousIndex)
        
        return vcs[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = vcs.firstIndex(of: viewController) else {
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
        
        vcs[nextIndex] = createControllerFor(page: nextIndex)
        
        return vcs[nextIndex]
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let i = vcs.firstIndex(of: pageViewController.viewControllers!.first!)
        currentPage = i ?? 0
        if finished && completed {
            let i = vcs.firstIndex(of: pageViewController.viewControllers!.first!)
            updatePager(currentPage: i ?? -1)
        }
        
        // Pause all videos.
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for vc in vcs {
            if let v = vc as? VideoPlayerController {
                v.pause()
            }
        }
        
        vcs.removeAll()
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
        
        for _ in urls {
            vcs.append(UIViewController())
        }
//        for url in urls {
//            if url.ext == ".webm" {
//                vcs.append(videoVC(url: URL(string: "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(url.tim!)\(url.ext!)")!))
//            } else {
//                vcs.append(imageVC(url: URL(string: "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(url.tim!)\(url.ext!)")!))
//            }
//        }
        
        moreButton = UIButton()
        moreButton?.setTitle("More", for: .normal)
        moreButton?.sizeToFit()
        view.addSubview(moreButton!)
        moreButton?.translatesAutoresizingMaskIntoConstraints = false
        moreButton?.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        moreButton?.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
        moreButton?.addTarget(self, action: #selector(moreButtonPressed(_:)), for: .touchUpInside)
        
        
        let blur = UIBlurEffect(style: .dark)
        let effect = UIVisualEffectView(effect: blur)
        effect.frame = view.bounds
        
        view.insertSubview(effect, at: 0)
        updatePager(currentPage: currentPage)
        
        
        vcs[currentPage] = createControllerFor(page: currentPage)
        setViewControllers([vcs[currentPage]], direction: .forward, animated: true, completion: nil)
    }
    
    private func createControllerFor(page: Int) -> UIViewController {
        let url = urls[page]
        if url.ext == ".webm" {
            return videoVC(url: URL(string: "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(url.tim!)\(url.ext!)")!)
        } else {
            return imageVC(url: URL(string: "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(url.tim!)\(url.ext!)")!)
        }
    }
    
    @objc private func moreButtonPressed(_ sender: AnyObject) {
        let menu = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
        menu.addAction(UIAlertAction(title: "Download this", style: .default, handler: { _ in
            self.downloadCurrentFile()
        }))
        menu.addAction(UIAlertAction(title: "Download all", style: .default, handler: nil))
        menu.addAction(UIAlertAction(title: "Filter posts with this file", style: .default, handler: nil))
        menu.addAction(UIAlertAction(title: "Search using IQDB", style: .default, handler: { _ in
            self.searchUsingIQDB()
        }))
        menu.addAction(UIAlertAction(title: "Search using Yandex", style: .default, handler: { _ in
            self.searchUsingYandex()
        }))
        menu.addAction(UIAlertAction(title: "Search using Google", style: .default, handler: { _ in
            self.searchUsingGoogle()
        }))
        menu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(menu, animated: true)
    }
    
    private func searchUsingGoogle() {
        for it in vcs {
            if let v = it as? VideoPlayerController {
                v.pause()
            }
        }
        
        var imgUrlStr = ""
        if urls[currentPage].ext == ".webm" {
            imgUrlStr = "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(urls[currentPage].tim!)s.jpg"
        } else {
            imgUrlStr = "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(urls[currentPage].tim!)\(urls[currentPage].ext!)"
        }
//         = urls[currentPage].absoluteString
        
        if imgUrlStr.hasPrefix("https://") {
            imgUrlStr = imgUrlStr[8...]
        }
        if imgUrlStr.hasPrefix("http://") {
            imgUrlStr = imgUrlStr[7...]
        }
        
        imgUrlStr = imgUrlStr.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        guard let url = URL(string: "https://www.google.com/searchbyimage?image_url=" + imgUrlStr) else {
            SPAlert.present(title: "Couldn't open URL", message: nil, preset: .error)
            return
        }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    private func searchUsingYandex() {
        for it in vcs {
            if let v = it as? VideoPlayerController {
                v.pause()
            }
        }
        
        var imgUrlStr = ""
        if urls[currentPage].ext == ".webm" {
            imgUrlStr = "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(urls[currentPage].tim!)s.jpg"
        } else {
            imgUrlStr = "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(urls[currentPage].tim!)\(urls[currentPage].ext!)"
        }
        
        guard let url = URL(string: "https://www.yandex.com/images/search?rpt=imageview&img_url=" + imgUrlStr) else {
            SPAlert.present(title: "Couldn't open URL", message: nil, preset: .error)
            return
        }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    private func searchUsingIQDB() {
        for it in vcs {
            if let v = it as? VideoPlayerController {
                v.pause()
            }
        }
        
        var imgUrlStr = ""
        if urls[currentPage].ext == ".webm" {
            imgUrlStr = "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(urls[currentPage].tim!)s.jpg"
        } else {
            imgUrlStr = "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(urls[currentPage].tim!)\(urls[currentPage].ext!)"
        }
        
        guard let url = URL(string: "http://iqdb.org/?url=" + imgUrlStr) else {
            SPAlert.present(title: "Couldn't open URL", message: nil, preset: .error)
            return
        }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    private func updatePager(currentPage: Int) {
        if pager == nil {
            pager = UILabel()
            view.addSubview(pager!)
            pager?.textColor = .white
        }

        if vcs.count > 0 {
            pager?.text = "\(mod(currentPage, vcs.count) + 1)/\(vcs.count)"
        }
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
        
        img.kf.setImage(with: .network(url),  progressBlock: { receivedSize, totalSize in
            print(receivedSize, totalSize)
        })
        
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

    func downloadCurrentFile () {
        PHPhotoLibrary.requestAuthorization({ status in
            if status != .authorized {
                DispatchQueue.main.async {
                    SPAlert.present(title: "Permission to save files denied", message: nil, preset: .error)
                }
                return
            }
            guard let url = URL(string: "https://i.4cdn.org/\(DataHolder.shared.currentThread.board)/\(self.urls[self.currentPage].tim!)\(self.urls[self.currentPage].ext!)") else {
                DispatchQueue.main.async {
                    SPAlert.present(title: "URL is invalid", message: nil, preset: .error)
                }
                return
            }
            
            self.saveImage(photoURL: url, toAlbum: "iChan", completionHandler: { a, b in
                DispatchQueue.main.async {
                    SPAlert.present(title: "File saved", message: nil, preset: .done)
                }
            })
        })
    }
    
    func createAlbum(withTitle title: String, completionHandler: @escaping (PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            var placeholder: PHObjectPlaceholder?

            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
                placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { (created, error) in
                var album: PHAssetCollection?
                if created {
                    let collectionFetchResult = placeholder.map { PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [$0.localIdentifier], options: nil) }
                    album = collectionFetchResult?.firstObject
                }

                completionHandler(album)
            })
        }
    }
    
    func getAlbum(title: String, completionHandler: @escaping (PHAssetCollection?) -> ()) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", title)
            let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let album = collections.firstObject {
                completionHandler(album)
            } else {
                self?.createAlbum(withTitle: title, completionHandler: { (album) in
                    completionHandler(album)
                })
            }
        }
    }
    
    func saveImage(photoURL: URL, toAlbum titled: String, completionHandler: @escaping (Bool, Error?) -> ()) {
        getAlbum(title: titled) { (album) in
            DispatchQueue.global(qos: .background).async {
                PHPhotoLibrary.shared().performChanges({
                    do {
                        let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: try Data(contentsOf: photoURL))!)
                        let assets = assetRequest.placeholderForCreatedAsset
                            .map { [$0] as NSArray } ?? NSArray()
                        let albumChangeRequest = album.flatMap { PHAssetCollectionChangeRequest(for: $0) }
                        albumChangeRequest?.addAssets(assets)
                    } catch {
                        print(error.localizedDescription)
                    }
                }, completionHandler: { (success, error) in
                    completionHandler(success, error)
                })
            }
        }
    }
    
    func createPhotoLibraryAlbum(name: String) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    fatalError("Album placeholder is nil")
                }

                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album: PHAssetCollection = fetchResult.firstObject else {
                    // FetchResult has no PHAssetCollection
                    return
                }

                // Saved successfully!
                print(album.assetCollectionType)
            }
            else if let e = error {
                // Save album failed with error
            }
            else {
                // Save album failed with no error
            }
        })
    }
}
