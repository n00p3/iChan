//
//  Utils.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import RealmSwift

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
