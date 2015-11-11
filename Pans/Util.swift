//
//  Util.swift
//  Pans
//
//  Created by Daniel Sandoval on 11/11/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation

extension UIViewController
{
    func displayError(error: NSError)
    {
        self.displayError(error, completion: nil)
    }
    
    func displayError(error: NSError, completion: (() -> Void)?)
    {
        self.displayAlert("Error", message: error.localizedDescription, completion: completion)
    }
    
    func displayAlert(title : String, message : String, completion: (() -> Void)?)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default)
            { (_ : UIAlertAction) in
                if let compl = completion {
                    compl()
                }
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}