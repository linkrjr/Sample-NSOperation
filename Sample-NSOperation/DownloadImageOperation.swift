//
//  DownloadImageOperation.swift
//  Sample-NSOperation
//
//  Created by Ronaldo GomesJr on 23/07/2015.
//  Copyright © 2015 Technophile IT. All rights reserved.
//

import UIKit

class DownloadImageOperation: Operation, NSURLSessionDownloadDelegate {

    var targetPath:String!
    var imageURL:NSURL!
    
    var downloadTask:NSURLSessionDownloadTask?
    var progressBlock: (Float) -> () = { _ in}
    
    init(imageURL:NSURL, targetPath:String) {
        self.imageURL = imageURL
        self.targetPath = targetPath
    }
    
    lazy var session:NSURLSession = {
        let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        return NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    
    override func execute() {
        self.downloadTask = session.downloadTaskWithURL(imageURL)
        downloadTask?.resume()
        
        
    }

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            self!.progressBlock(progress)
        }
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        let targetURL = NSURL(fileURLWithPath: targetPath)
        do {
            
            if fileManager.fileExistsAtPath(targetPath) {
                print("Deleting current copy")
                try! fileManager.removeItemAtPath(targetPath)
            }
            
            try NSFileManager.defaultManager().copyItemAtURL(location, toURL: targetURL)
            finish()
        } catch {
            fatalError("Couldn't copy")
        }
        
    }
    
}
