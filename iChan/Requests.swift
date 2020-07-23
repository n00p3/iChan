//
//  Requests.swift
//  iChan
//
//  Created by Mateusz Głowski on 20/05/2020.
//  Copyright © 2020 Mateusz Głowski. All rights reserved.
//

import Foundation
import Alamofire


struct LastRequested {
    var boards:  Date?
    var threads: Date?
    var catalog: [String:Date]?
    var posts:   Date?
}

class Requests {
    enum Error: Swift.Error {
        case deserializationError
        case notOk
    }
    
    static var lastRequested = LastRequested()
    
    /**
     A list of all boards and their attributes.
     */
    static func boards(success: @escaping (BoardsJSON) -> (), failure: @escaping (Error) -> ()) {
        var h = HTTPHeaders()
        if lastRequested.boards != nil {
            h["If-Modified-Since"] = self.lastRequested.boards!.toRFC1123()
        }
        
        AF.request("https://a.4cdn.org/boards.json", headers: h)
            .responseDecodable(of: BoardsJSON.self) { response in
                if response.response?.statusCode != 200 {
                    failure(.notOk)
                    return
                }
                
                guard let boards = response.value else {
                    failure(.deserializationError)
                    return
                }
            
                lastRequested.boards = Date()
                success(boards)
                
            }
    }
    
    /**
     A summarized list of all threads on a board including thread numbers, their modification time and reply count.
     - Parameter board: Name of a board.
     */
    static func threads(of board: String, success: @escaping (Threads4Chan) -> (), failure: @escaping (Error) -> ()) {
        var h = HTTPHeaders()
        if lastRequested.threads != nil {
            h["If-Modified-Since"] = self.lastRequested.boards!.toRFC1123()
        }
        
        AF.request("https://a.4cdn.org/\(board)/threads.json", headers: h)
            .responseDecodable(of: Threads4Chan.self) { response in
                if response.response?.statusCode != 200 {
                    failure(.notOk)
                    return
                }
                
                guard let threads = response.value else {
                    failure(.deserializationError)
                    return
                }
            
                lastRequested.threads = Date()
                success(threads)
            }
        
    }
    
    /**
     A JSON representation of a board catalog. Includes all OPs and their preview replies.
     */
    static func catalog(of board: String, success: @escaping (Catalog) -> (), failure: @escaping (Error) -> ()) {
        print("Reading catalog from api")
        var h = HTTPHeaders()
        if lastRequested.catalog?[board] != nil {
            h["If-Modified-Since"] = self.lastRequested.catalog?[board]?.toRFC1123()
        }
        
        AF.request("https://a.4cdn.org/\(board)/catalog.json", headers: h)
            .responseDecodable(of: Catalog.self) { response in
                if response.response?.statusCode == 304 {
                    print("304 - Reading from cache")
                    guard let x = readCatalogFromRealm(board: board) else {
                        failure(.notOk)
                        return
                    }
                    success(x)
                    
                    return
                }
                
                if response.response?.statusCode != 200 {
                    failure(.notOk)
                    return
                }
                
                guard let catalog = response.value else {
                    failure(.deserializationError)
                    return
                }
                
//                lastRequested.catalog = Date()
                if lastRequested.catalog == nil {
                    lastRequested.catalog = [String:Date]()
                }

                lastRequested.catalog![board] = Date()
                
                storeCatalogInRealm(board: board, liveCatalog: catalog)
                
                success(catalog)
        }
    }
    
    /**
     A full list of posts in a single thread.
     */
    static func posts(_ board: String, no: Int, success: @escaping (Posts) -> (), failure: @escaping (Error) -> ()) {
        var h = HTTPHeaders()
        if lastRequested.boards != nil {
            h["If-Modified-Since"] = self.lastRequested.boards!.toRFC1123()
        }

        let url = "https://a.4cdn.org/\(board)/thread/\(no).json"
        AF.request(url, headers: h)
            .responseDecodable(of: Posts.self) { response in
                if response.response?.statusCode != 200 {
                    failure(.notOk)
                    return
                }

                guard let posts = response.value else {
                    failure(.deserializationError)
                    return
                }

                lastRequested.posts = Date()
                success(posts)
        }
    }
    
    /**
     Returns specific image.
     - Parameter fullSize: Should it get fullsize or thumbnail?
     */
    static func image(_ board: String, _ tim: Int, _ ext: String, fullSize: Bool, callback: @escaping (UIImage?) -> ()) {
        var myExt = ""
        let size: String = {
            if fullSize {
                myExt = ext
                return ""
            } else {
                myExt = ".jpg"
                return "s"
            }
        }()
        
        let url = "https://i.4cdn.org/\(board)/\(tim)\(size)\(myExt)"
        print(url)
        AF.request(url)
            .response { request in
                if request.data == nil {
                    callback(nil)
                    return
                }

                let img = UIImage(data: request.data!)
                callback(img)
        }
    }
}
