//
//  FreeSpaceOperation.swift
//  Sample-NSOperation
//
//  Created by Ronaldo GomesJr on 23/07/2015.
//  Copyright © 2015 Technophile IT. All rights reserved.
//

import Foundation

class FreeSpaceOperation: NSOperation {

    var fileSystemAttributes: NSDictionary?
    var error: NSError?
    
    let path:String
    
    init(path:String) {
        self.path = path
    }
    
    override func main() {
        
        let fileManager = NSFileManager.defaultManager()
        
        for i in (1...5).reverse() {
            print("Sleeping \(i)")
            if cancelled {
                return
            }
            sleep(1)
        }

        if cancelled {
            return
        }
        
        let attribs = try! fileManager.attributesOfFileSystemForPath(self.path)
        
        print("Attributes for \(self.path): \(attribs)")
        
        self.fileSystemAttributes = attribs
        
    }
    
}
