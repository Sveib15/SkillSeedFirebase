//
//  InitialDescView.swift
//  HHR
//
//  Created by Anders Berntsen on 10.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class InitialDescView: UIViewController {
    
    var ref: DatabaseReference!

    @IBOutlet weak var descEdited: UITextView!
    var initialDesc : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //saves, and dismisses the view
    @IBAction func descDone(_ sender: Any) {
        initialDesc = descEdited.text
        
        //Gets the user ID for the current user
        guard let uid = Auth.auth().currentUser?.uid
            else {
                return
        }
        //Pushes info to database
        let value = ["Description": initialDesc]
        ref?.child("userInfo").child(uid).updateChildValues(value, withCompletionBlock: {(err, ref) in
        
        //Errorhandling
        if err != nil {
            print(err!)
            return
        }
            print("SUCCESSFULLY PUSHED DESCRIPTION TO DATABASE")
        })

        //Last thing before class is destroyed
        dismiss(animated: true, completion: nil)
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
