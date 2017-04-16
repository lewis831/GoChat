//
//  LoginViewController.swift
//  GoChat
//
//  Created by Lewis Rashe on 4/13/17.
//  Copyright © 2017 Lewis Rashe. All rights reserved.
//

import UIKit
import GoogleSignIn

//Added GIDSignInUIDelegate to fix error related to GoogleSignIn
//Error: Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'uiDelegate must either be a |UIViewController| or implement the |signIn:presentViewController:| and |signIn:dismissViewController:| methods from |GIDSignInUIDelegate|.'
//Added GIDSignInDelegate
class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    
    @IBOutlet weak var anonymousButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //anonymousButton:
        //set border color white and width
        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        
        //GoogleSignIn client ID pulled from the import GoogleSignIn package
        //To get client ID copy/paste from GoogleServices-Info.plist file the value in CLIENT_ID
        GIDSignIn.sharedInstance().clientID = "469975431945-jl1242u0mubkqmtbdg2ghirfo0d47jop.apps.googleusercontent.com"
        
        //Added to fix uiDelegate error details found at the top
        //Code below lets GIDSignIn that UIViewController will show GoogleSignIn Screen
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAnonymouslyDidTapped(_ sender: Any) {
        //Important note of what this code does: Anonymously log user in and switch view
        //switch view by setting navigation controller as root view controller
        
        //Calling code found in Helper.swift file
        Helper.helper.loginAnonymously()
      
    }
    
    @IBAction func googleLoginDidTapped(_ sender: Any) {
        print("google login did tapped")
        
        //GoogleSignIn pulled from the import GoogleSignIn package
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    //This line was generated by debugger to fix and work with GIDSignInDelegate
    //If working properly <GIDAuthentication: ''> should appear in console
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        print(user.authentication)
            
        //Calling code found in Helper.swift file
        Helper.helper.logInWithGoogle(authentication: user.authentication)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
