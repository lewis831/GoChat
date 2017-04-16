//
//  Helper.swift
//  GoChat
//
//  Created by Lewis Rashe on 4/15/17.
//  Copyright © 2017 Lewis Rashe. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn

class Helper {
    static let helper = Helper()
    
    func loginAnonymously() {
        print("login anonymously did tapped")
        //Important note of what this code does: Anonymously log user in and switch view
        //switch view by setting navigation controller as root view controller
        
        //Anonymous user authetication with Firebase
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser, error) in
            if error == nil {
                //Displays UserId in console
                print("UserId: \(anonymousUser!.uid)")
                
                //Calling code function 'switchToNavigationViewController()' found below
                self.switchToNavigationViewController()
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    
    //Firebase authentication with GoogleSignIn
    //If working correctly the following should be displayed in the console:
    //Optional("lewisrashe831@gmail.com")
    //Optional("Lewis Benji")

    func logInWithGoogle(authentication: GIDAuthentication) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            } else {
                print(user?.email as Any)
                print(user?.displayName as Any)
                
                //Calling code function 'switchToNavigationViewController()' found below
                self.switchToNavigationViewController()
            }
        })
    }
    
    private func switchToNavigationViewController() {
        //Create a main storyboard instance
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //From main storyboard instantiate a navigation controller
        //To connect this code go to Main.storyboard -> Navigation Controller -> identity inspector -> Storyboard ID -> enter value: "NavigationVC"
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        //Get the app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //Set Navigation Controller as root view controller
        appDelegate.window?.rootViewController = naviVC
    }
}
