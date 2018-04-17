//
//  MyProfileController.swift
//  HHR
//
//  Created by Anders Berntsen on 15.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class MyProfileController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()
    var imageUrlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gets the userID as uid
        guard let uid = Auth.auth().currentUser?.uid
            else {
                return
        }
        //sets database referance
        ref = Database.database().reference()
        
        //Sets the image as a circle
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        let imageRef = ref.child("userInfo").child(uid).child("profileImage")
        imageRef.observeSingleEvent(of: .value) { (snapshot) in
            self.imageUrlString = snapshot.value as? String
        }
        let imageUrl = URL(string: imageUrlString!)
        let imageData = NSData(contentsOf: imageUrl!)
        
        
    }//end viewDidLoad

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
