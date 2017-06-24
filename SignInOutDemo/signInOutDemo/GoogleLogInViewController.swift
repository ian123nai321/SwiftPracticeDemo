//
//  ViewController.swift
//  signInOutDemo
//
//  Created by 吳政緯 on 2017/6/22.
//  Copyright © 2017年 吳政緯. All rights reserved.
//

import UIKit
import GoogleSignIn

class GoogleLogInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    var googleSignInButtonByCode : GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        googleSignInButtonByCode = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        view.addSubview(googleSignInButtonByCode)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GIDSignIn.sharedInstance().signOut()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        googleSignInButtonByCode.center = view.center
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil{
            print(error)
            return
        }else{
            
            print(user.userID)
            print(user.profile.email)
            print(user.profile.imageURL(withDimension: 400))
        }
    }
    
    @IBAction func googleSignOut(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().signOut()
    }
    
    
    
}

