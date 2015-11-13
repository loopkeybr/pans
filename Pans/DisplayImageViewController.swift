//
//  DisplayImageViewController.swift
//  Pans
//
//  Created by Daniel Sandoval on 11/12/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation

class DisplayImageViewController : UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var secondsLabel: UILabel!
    
    var seconds = 5
    
    var image : UIImage?
    
    var timer : NSTimer?
    
    override func viewWillAppear(animated: Bool)
    {
        showTimer()
        self.imageView.image = image
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self,
            selector: Selector("fireTimer"), userInfo: nil, repeats: true)
    }
    
    func fireTimer()
    {
        seconds--
        showTimer()
        if (seconds <= 0) {
            timer?.invalidate()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
        }
    }
    
    func showTimer()
    {
        secondsLabel.text = String(format: "%02d", arguments: [seconds])
    }
    
}