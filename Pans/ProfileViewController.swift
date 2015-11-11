//
//  ProfileViewController.swift
//  Pans
//
//  Created by Daniel Sandoval on 11/11/15.
//  Copyright © 2015 Loop CE. All rights reserved.
//

import Foundation
import SwiftForms
import SwiftOverlays

class ProfileViewController : FormViewController
{
    
    var user: PFUser?
    
    override func viewDidLoad()
    {
        self.user = PFUser.currentUser()
        
        let form = FormDescriptor()
        let section1 = FormSectionDescriptor()
        section1.headerTitle = "User Info"
        let usernameRow = FormRowDescriptor(tag: "username", rowType: .Text, title: "Username", placeholder: "BugsBunny")
        usernameRow.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(usernameRow)
        let emailRow = FormRowDescriptor(tag: "email", rowType: .Email, title: "E-mail", placeholder: "bunny@bugs.com")
        emailRow.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(emailRow)
        
        let section2 = FormSectionDescriptor()
        let saveRow = FormRowDescriptor(tag: "submit", rowType: .Button, title: "Update")
        saveRow.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
            self.updateInfoAndSaveUser()
        }
        
        section2.addRow(saveRow)
        
        form.sections = [section1, section2]
        self.form = form
        
        if let user = self.user {
            fillUserInfo()
            if user.isNew {
                SwiftOverlays.showBlockingWaitOverlay()
                // Get user information from Facebook
                let requestParams = ["fields" : "name,email"]
                FBSDKGraphRequest(graphPath: "me", parameters: requestParams).startWithCompletionHandler()
                    { (connection: FBSDKGraphRequestConnection?, result: AnyObject?, error: NSError?) -> Void in
                        if let fbData = result as? NSDictionary {
                            if let email = fbData["email"] as? String {
                                user.email = email
                            }
                            let username = (fbData["name"] as! String).stringByReplacingOccurrencesOfString(" ", withString: "")
                            self.isUsernameAvailable(username) { (available: Bool, error: NSError?) -> Void in
                                if error == nil && available {
                                    user.username = username
                                }
                                self.fillUserInfo()
                                SwiftOverlays.removeAllBlockingOverlays()
                                self.saveUser()
                            }
                        } else {
                            self.displayAlert("Error", message: "Failed to retrieve facebook user info.", completion: nil)
                            SwiftOverlays.removeAllBlockingOverlays()
                        }
                }
            }
        }
        
        super.viewDidLoad()
    }
    
    func isUsernameAvailable(username: String, completion: ((Bool, NSError?) -> Void))
    {
        if let q = PFUser.query() {
            q.whereKey("username", equalTo: username)
            q.countObjectsInBackgroundWithBlock()
                { (count : Int32, error : NSError?) -> Void in
                    completion(count == 0 ? true : false, error)
            }
        }
    }
    
    func fillUserInfo()
    {
        self.setValue(self.user?.username, forTag: "username")
        self.setValue(self.user?.email, forTag: "email")
    }
    
    override func setValue(value: NSObject?, forTag tag: String) {
        if let v = value {
            super.setValue(v, forTag: tag)
        }
    }
    
    func saveUser()
    {
        self.saveUser() {
            (saved: Bool, error: NSError?) -> Void in
            if let e = error {
                self.displayAlert("Failed to Save", message: e.localizedDescription, completion: nil)
            }
        }
    }
    
    func saveUser(completion : ((saved: Bool, error: NSError?) -> Void)?)
    {
        self.user?.saveInBackgroundWithBlock()
            { (saved: Bool, error: NSError?) -> Void in
                if !saved, let e = error {
                    self.displayAlert("Error", message: e.localizedDescription, completion: nil)
                }
                if let c = completion {
                    c(saved: saved, error: error)
                }
        }
    }
    
    func updateInfoAndSaveUser()
    {
        SwiftOverlays.showBlockingWaitOverlay()
        self.user?.email = self.valueForTag("email") as? String
        if let username = self.valueForTag("username") as? String {
            if (self.user?.username != username) {
                self.isUsernameAvailable(username)
                    { (available, error: NSError?) -> Void in
                        if available {
                            self.user?.username = username
                        } else if let e = error {
                            self.displayError(e)
                        } else {
                            self.displayAlert("Username Unavailable", message: "This username is already taken.", completion: nil)
                            self.setValue(self.user?.username, forTag: "username")
                        }
                        self.saveUser()
                        SwiftOverlays.removeAllBlockingOverlays()
                }
            } else {
                self.saveUser()
                SwiftOverlays.removeAllBlockingOverlays()
            }
        }
    }
    
}