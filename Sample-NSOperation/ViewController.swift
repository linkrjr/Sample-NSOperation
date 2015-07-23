//
//  ViewController.swift
//  Sample-NSOperation
//
//  Created by Ronaldo GomesJr on 23/07/2015.
//  Copyright © 2015 Technophile IT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var textView:UITextView!
    @IBOutlet var goButton:UIButton!
    @IBOutlet var cancelButton:UIButton!
    
    let operationQueue = NSOperationQueue()
    
    var operationsInQueueLimit = 3
    var operationsInQueue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.operationQueue.maxConcurrentOperationCount = 2
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goButtonClicked(sender: AnyObject) {
        self.cancelButton.enabled = true
        self.goButton.enabled = false

        self.computeFreeSpaceFor(path: "/")
    }

    @IBAction func cancelButtonClicked(sender: AnyObject) {
    }
    
    
    private func computeFreeSpaceFor(path path: String) {
        let operation = FreeSpaceOperation(path: path)
        
        appendText("Computing free space for \(path) ...")
        
        operation.completionBlock = { [weak self] in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if operation.cancelled {
                    self!.appendText("Cancelled")
                } else {
                    if let spaceFree = operation.fileSystemAttributes?[NSFileSystemFreeSize] as? NSNumber {
                        let spaceFreeBytes = spaceFree.longLongValue
                        let spaceFreeString = NSByteCountFormatter.stringFromByteCount(spaceFreeBytes, countStyle: NSByteCountFormatterCountStyle.File)
                        self!.appendText("Free space on \(operation.path): \(spaceFreeString)")
                    }
                }
                self?.cancelButton.enabled = false
                self?.goButton.enabled = true
            })
        }
        
        self.operationQueue.suspended = true
        self.operationQueue.addOperation(operation)
        self.operationsInQueue += 1
        
        //        if self.operationsInQueue == self.operationsInQueueLimit {
        self.operationsInQueue = 0
        self.operationQueue.suspended = false
        //        }
    }
    
    func appendText(text: String) {
        textView.textStorage.appendAttributedString(NSAttributedString(string: "\(text)"))
    }
}

