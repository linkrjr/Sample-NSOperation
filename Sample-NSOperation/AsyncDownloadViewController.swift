//
//  AsyncDownloadViewController.swift
//  Sample-NSOperation
//
//  Created by Ronaldo GomesJr on 23/07/2015.
//  Copyright © 2015 Technophile IT. All rights reserved.
//

import UIKit

class AsyncDownloadViewController: UIViewController {

    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var imageView:UIImageView!
    let operationQueue = NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func downloadButtonClicked(sender: AnyObject) {
        let url = NSURL(string: "http://imgsrc.hubblesite.org/hu/db/images/hs-2006-10-a-hires_jpg.jpg")
        
        let docsDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! as String
        let targetPath = docsDir.stringByAppendingPathComponent("huddle.jpg")
        
        let downloadOperation = DownloadImageOperation(imageURL: url!, targetPath: targetPath)
        downloadOperation.progressBlock = { self.downloadProgressView.progress = $0 }
        
        downloadOperation.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let image = UIImage(contentsOfFile: targetPath) {
                    self.displayImage(image)
                    print(image)
                }
            })
        }
        
        operationQueue.addOperation(downloadOperation)
    }

    private func displayImage(image:UIImage) {
        self.imageView.image = image
    }
    
    
}
