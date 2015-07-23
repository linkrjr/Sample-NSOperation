//
//  BackgroundSessionsViewController.swift
//  Sample-NSOperation
//
//  Created by Ronaldo GomesJr on 23/07/2015.
//  Copyright © 2015 Technophile IT. All rights reserved.
//

import UIKit

class BackgroundSessionsViewController: UIViewController, NSURLSessionDownloadDelegate {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var imageView: UIImageView!
    
    var session:NSURLSession {
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("it.technophile.background")
        return NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    var backgroundCompletionHandler:() -> () = { _ in }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressBar.hidden = true
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "promptForDelete:")
        self.view.addGestureRecognizer(longPressRecognizer)
        
        if (self.localImageExists()) {
            self.loadImage()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleBackgroundSession:", name: "BackgroundSessionUpdate", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func handleBackgroundSession(notification:NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let vo = userInfo["vo"] as! ValueObject
        if vo.identifier == self.session.configuration.identifier {
            self.backgroundCompletionHandler = vo.completionHandler
        }
    }

    private func localImageExists() -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(self.localImagePath())
    }
    
    private func localImagePath() -> String {
        let docsDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! as String
        let targetPath = docsDir.stringByAppendingPathComponent("image.jpg")
        return targetPath
    }
    
    private func loadImage() {
        let image = UIImage(contentsOfFile: self.localImagePath())
        self.imageView.image = image
    }
    
    func promptForDelete(recognizer:UILongPressGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.Began) {
            if (!self.localImageExists()) {
                return
            }
            
            let alertViewController = UIAlertController(title: "Delete Image?", message: "Remove Image", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            let removeButton = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (_  ) -> Void in
                
                
                
            })
            alertViewController.addAction(cancelButton)
            alertViewController.addAction(removeButton)
            
            self.presentViewController(alertViewController, animated: true, completion: nil)
        }
    }
    
    private func deleteLocalImage() {
        self.imageView.image = nil
        try! NSFileManager.defaultManager().removeItemAtPath(self.localImagePath())
    }
    
    @IBAction func downloadButtonTapped(sender: AnyObject) {
        self.progressBar.hidden = false
        self.progressBar.progress = 0
        let imageURL = NSURL(string: "http://imgsrc.hubblesite.org/hu/db/images/hs-2006-14-a-2560x1024_wallpaper.jpg")
        let task = self.session.downloadTaskWithURL(imageURL!)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        task?.resume()
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        self.backgroundCompletionHandler()
        self.backgroundCompletionHandler = { _ in }
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if ((error) != nil) {
            print(error?.description)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        do {
            try NSFileManager.defaultManager().copyItemAtURL(location, toURL: NSURL(fileURLWithPath: self.localImagePath()))
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.loadImage()
                self.progressBar.hidden = true
                
            })
            
        } catch {
            print("Copy file error")
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.progressBar.progress = progress
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
    
}
