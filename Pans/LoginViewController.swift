//
//  ViewController.swift
//  Pans
//
//  Created by Daniel Sandoval on 11/11/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("loginWithoutAnimation", sender: self)
        }
    }

    @IBAction func didPressLoginWithFacebook(sender: UIButton)
    {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["email", "user_about_me", "public_profile", "user_friends"]) {
            (userOptional: PFUser?, errorOptional: NSError?) -> Void in
            if let user = userOptional {
                let installation = PFInstallation.currentInstallation()
                installation.setObject(user, forKey: "user")
                installation.saveInBackground()
                self.performSegueWithIdentifier("login", sender: self)
            } else if errorOptional != nil {
                NSLog("Failed to login")
            } else {
                NSLog("User cancelled login.")
            }
        }
    }

}

