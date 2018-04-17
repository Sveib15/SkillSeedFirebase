//
//  EditDescriptioController.swift
//  HHR
//
//  Created by Anders Berntsen on 17.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class EditDescriptioController: UIViewController {

    @IBOutlet weak var Description: UITextView!
    var ref: DatabaseReference!
    var DescPost : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeDesc)), animated: true)
        
        Description.becomeFirstResponder()
        
        ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        let descRef = ref.child("userInfo").child(uid!).child("Description")
        descRef.observeSingleEvent(of: .value) { (snapshot) in
            self.Description.text = snapshot.value as? String
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func composeDesc() {
        let uid = Auth.auth().currentUser?.uid
        DescPost = Description.text
        let value = ["Description": DescPost]
        ref?.child("userInfo").child(uid!).updateChildValues(value, withCompletionBlock: {(err, ref) in
            //Errorhandling
            if err != nil {
                print(err!)
                return
            }
            print("SUCCESSFULLY PUSHED DESCRIPTION TO DATABASE")
            Shared.shared.tabBarIndex = 3
            let RegController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
            self.present(RegController!, animated: true, completion: nil)
        })
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
