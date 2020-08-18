//
//  Utils.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift
import Lightbox
import SPAlert
import Player
import AVKit
import AVFoundation
import SDWebImage

extension Date {
    func toRFC1123() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM YYYY HH:mm:SS 'GMT'"
        return formatter.string(from: self)
    }
}

func initDB() {
    let config = Realm.Configuration(
        // Set the new schema version. This must be greater than the previously used
        // version (if you've never set a schema version before, the version is 0).
        schemaVersion: 2,

        // Set the block which will be called automatically when opening a Realm with
        // a schema version lower than the one set above
        migrationBlock: { migration, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if (oldSchemaVersion < 1) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        })

    // Tell Realm to use this new configuration object for the default Realm
    Realm.Configuration.defaultConfiguration = config

    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
       
    let realm = try! Realm()
    let settings = realm.objects(Settings.self)
    if settings.count != 0 {
        return
    }
    
    try! realm.write {
        realm.add(Settings())
    }
}

/**
 Reads locally stored catalog for specific board.
 - Parameter board: Board name.
 */
func readCatalogFromRealm(board: String) -> Catalog? {
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

        let threadsAtPage = Array(catalogs).filter { $0.page == page }

        var threads = [CatalogThread]()
        threadsAtPage.forEach {
            let thread = CatalogThread(no: $0.no, sticky: $0.sticky, closed: $0.closed, now: String($0.closed), name: $0.name, sub: $0.sub, com: $0.com, filename: $0.filename, ext: $0.ext, w: nil, h: nil, tnW: nil, tnH: nil, tim: $0.tim, time: nil, md5: nil, fsize: nil, resto: nil, capcode: nil, semanticURL: nil, replies: nil, images: nil, omittedPosts: nil, omittedImages: nil, lastReplies: nil, lastModified: nil, bumplimit: nil, imagelimit: nil, trip: nil)

            threads.append(thread)
        }
        let catalogElement = CatalogElement(page: page, threads: threads)
        catalogElements.append(catalogElement)
    }

    return catalogElements
}

/**
 Saves catalog in local memory for faster access. Removes previously stored catalog for specific board.
 - Parameter board: Board name.
 - Parameter liveCatalog: Catalog freshly fetched from 4chan API.
 */
func storeCatalogInRealm(board: String, liveCatalog: Catalog) {
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
                newCatalogThread.ext = $0.ext ?? ""
                newCatalogThread.tim = $0.tim ?? 0
                newCatalogThread.no = $0.no
                newCatalogThread.lastAccessed = Date()
                newCatalogThread.page = element.page
                newCatalogThread.image = nil

                realm.add(newCatalogThread)
            }
        }
    }
}

extension String {
    func htmlToAttributedString(attrs: [NSAttributedString.Key : Any]) -> NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            var ret = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            ret.addAttributes(attrs, range: NSRange(location: 0, length: ret.string.count))
            return ret
        } catch {
            return nil
        }
    }
//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }
}

/**
 Downloads file and previews it.
 */
func filePreviewHandler(
    parent: UIViewController,
    board: String,
    tim: Int,
    ext: String) {

    if ext == ".webm" {
        let vc = UIStoryboard(name: "VideoPlayer", bundle: nil).instantiateViewController(withIdentifier: "VideoPlayerController") as! VideoPlayerController
        vc.videoURL = "https://i.4cdn.org/\(board)/\(tim)\(ext)"
        parent.present(vc, animated: true)
    } else if ext == ".gif" {
        let placeholder = UIImage(named: "placeholder")!
        
        let i = LightboxImage(image: placeholder)
        let controller = LightboxController(images: [i])
        controller.dynamicBackground = true
        
        let downloader = SDWebImageManager()
        downloader.loadImage(with: URL(string: "https://i.4cdn.org/\(board)/\(tim)\(ext)")!, options: .highPriority, progress: nil, completed: { (image, data, error, cacheType, finished, imageURL) in
            if error != nil || image == nil {
                SPAlert.present(title: "Error downloading gif", preset: .error)
                return
            }
            
            let v = UIImageView(image: image)
            v.frame = controller.view.bounds
            v.contentMode = .scaleAspectFit
            controller.view.subviews[2].addSubview(v)
        })
        
        parent.present(controller, animated: true)
    } else {
        let i = LightboxImage(imageURL: URL(string: "https://i.4cdn.org/\(board)/\(tim)\(ext)")!)
        let controller = LightboxController(images: [i])
        controller.dynamicBackground = true
        parent.present(controller, animated: true)
    }
}

extension UIImage {
    class func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func scale(image: UIImage, by scale: CGFloat) -> UIImage? {
        let size = image.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIImage.resize(image: image, targetSize: scaledSize)
    }
}

func mod(_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

//    Copyright (c) 2019, SeatGeek, Inc
//    All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions are met:
//
//    * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//    * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//    DispatchQueue+Dedupe.swift
//    Created by James Van-As on 21/09/18.
import Foundation

extension DispatchQueue {

    /**
     - parameters:
        - target: Object used as the sentinel for de-duplication.
        - delay: The time window for de-duplication to occur
        - work: The work item to be invoked on the queue.
     Performs work only once for the given target, given the time window. The last added work closure
     is the work that will finally execute.
     Note: This is currently only safe to call from the main thread.
     Example usage:
     ```
     DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
         self?.doTheWork()
     }
     ```
     */
    public func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
        let dedupeIdentifier = DispatchQueue.dedupeIdentifierFor(target)
        if let existingWorkItem = DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier) {
            existingWorkItem.cancel()
            NSLog("Deduped work item: \(dedupeIdentifier)")
        }
        let workItem = DispatchWorkItem {
            DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier)

            for ptr in DispatchQueue.weakTargets.allObjects {
                if dedupeIdentifier == DispatchQueue.dedupeIdentifierFor(ptr as AnyObject) {
                    work()
                    NSLog("Ran work item: \(dedupeIdentifier)")
                    break
                }
            }
        }

        DispatchQueue.workItems[dedupeIdentifier] = workItem
        DispatchQueue.weakTargets.addPointer(Unmanaged.passUnretained(target).toOpaque())

        asyncAfter(deadline: .now() + delay, execute: workItem)
    }

}

// MARK: - Static Properties for De-Duping
private extension DispatchQueue {

    static var workItems = [AnyHashable : DispatchWorkItem]()

    static var weakTargets = NSPointerArray.weakObjects()

    static func dedupeIdentifierFor(_ object: AnyObject) -> String {
        return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
    }

}
