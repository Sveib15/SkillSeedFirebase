//
//  ViewController.swift
//  HHR
//
//  Created by Svein Bruce on 09.02.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

//SCRAPCODE
/*
     (CUSTOM LOGIN BUTTON)
    @objc func handleCustomFBLogin(){
        let accessToken = FBSDKAccessToken.current()
        guard (accessToken?.tokenString) != nil else
        { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: (accessToken?.tokenString)!)
        //Check if user is firsttime user.
     
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print ("something went wrong with FB user", error ?? "")
            }
            self.showEmail()
            print("SUCCESSFULLY LOGGED IN WITH OUR USER: ", user ?? "")
        })
        
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil{
                print("FB login failed", err ?? "")
                return
            }
        }
        
        
    }
    
    func showEmail(){
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
            (connection, result, err) in
            
            if err != nil{
                print("failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
            
        }
        
    }
     
     
     (CHECKING IF USER IS SIGNING UP OR IN)
     let accessToken = FBSDKAccessToken.current()
     guard let accessTokenString = accessToken?.tokenString else {return}
     
     let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
     
     Auth.auth().signIn(with: credentials, completion: { (user, error) in
     let id = Auth.auth().currentUser?.uid
     let ref = Database.database().reference(withPath: "users")
     
     ref.child(id).observeSingleEvent(of: .value, with: {(snapshot) in
     if snapshot.exists() {
     //User is signing IN
     } else {
     //User is signing UP
     }
     }
     }
     
     
     
     
     

END OF SCRAPCODE
     */
    
}
