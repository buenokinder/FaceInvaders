//
//  GameViewController.swift
//  SKInvaders
//
//  Created by Riccardo D'Antoni on 15/07/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, FBSDKLoginButtonDelegate  {

    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
       
        if ((error) != nil)
        {
            
        } else if result.isCancelled {

        } else {
        
           
            if result.grantedPermissions.contains("email")
            {
                let skView = self.view as! SKView
                skView.showsFPS = true
                skView.showsNodeCount = true
                
                
                skView.ignoresSiblingOrder = true
                
                
                let scene = GameScene(size: skView.frame.size)
                skView.presentScene(scene)
                
                NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.handleApplicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.handleApplicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
            }
        }

    }

   let loginView : FBSDKLoginButton = FBSDKLoginButton()
  override func viewDidLoad() {
    super.viewDidLoad()
       print("teste");
    if (FBSDKAccessToken.current() != nil)
    {
       
        self.view.willRemoveSubview(loginView)
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
    
        skView.ignoresSiblingOrder = true

        let scene = GameScene(size: skView.frame.size)
        skView.presentScene(scene)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.handleApplicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.handleApplicationDidBecomeActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    else
    {
        
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
    }
    
   
  }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
       
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
            }
            else
            {
                
            }
        })
    }
   
  
  override var shouldAutorotate : Bool {
    return true
  }
  
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    
    return UIInterfaceOrientationMask.portrait
  }
  
  
  
  func handleApplicationWillResignActive (_ note: Notification) {
    
    let skView = self.view as! SKView
    skView.isPaused = true
  }
  
  func handleApplicationDidBecomeActive (_ note: Notification) {
    
    let skView = self.view as! SKView
    skView.isPaused = false
  }
  
}
