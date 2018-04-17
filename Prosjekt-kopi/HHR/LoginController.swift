//
//  LoginController.swift
//  HHR
//
//  Created by Anders Berntsen on 11.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginController: UIViewController {
    
    var ref: DatabaseReference!
    var sessionBool = false
    @IBOutlet weak var cusLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        cusLogin.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    @objc func handleCustomFBLogin(){
        let FBLoginManager = FBSDKLoginManager()
        FBLoginManager.logOut()
        FBLoginManager.logIn(withReadPermissions: ["public_profile"], from: self) { (result, err) in
            if err != nil{
                print("FB login failed", err ?? "")
                return
            }//end if err
            self.showEmail(completion: { (success) in
                if success{
                    self.changeViewController()
                } else {
                    print ("FIREBASE AUTH FAILED")
                    return
                }
            })
        }//end FBSDKLoginManager
    }//end handeCustomFBLogin
    
    func changeViewController(){
    guard let uid = Auth.auth().currentUser?.uid
    else{
    return
    }
        // check if user already logged in, if yes, then send it into the app without hassle,
        //if not run the code below
        if (FBSDKAccessToken.current() != nil) {

    checkUserSetup(userID: uid, completion: { (success) -> Void in
    if success{
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
    self.present(destinationController!, animated: true, completion: nil)
    } else {
        print("THE WILL NOT CHANGE")
        let RegController = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationController")
        self.present(RegController!, animated: true, completion: nil)
        }
        })
        }else{
            print("nothing happened")
        } //end if token
    } //end ChangeVC
    
    func showEmail(completion: @escaping ((_ success: Bool) ->Void)){
        
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else
        {return}
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: (accessTokenString))
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print ("something went wrong with FB user", error ?? "")
                completion(false)
            }
            print("SUCCESSFULLY LOGGED IN WITH OUR USER: ", user ?? "")
            completion(true)
        })
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
            (connection, result, err) in
            
            if err != nil{
                print("failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
    }
    func checkUserSetup(userID: String, completion: @escaping ((_ success: Bool) -> Void)){
        self.ref.child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            //var result: Bool
            
            if snapshot.hasChild(userID){
                print("DU HAR GÅTT GJENNOM SETUP!")
                completion(snapshot.hasChild(userID))
                print("HER ER VALUEN FOR TRUE", userID)
                //return true
            }else{
                print("DU HAR IKKE GÅTT GJENNOM SETUP")
                completion(false)
                //return false
            }
            //return result
        }
    )}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
