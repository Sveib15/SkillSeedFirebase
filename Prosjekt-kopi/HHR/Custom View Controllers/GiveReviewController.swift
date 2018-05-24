//
//  GiveReviewController.swift
//  HHR
//
//  Created by Anders Berntsen on 24.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class GiveReviewController: UIViewController {

    @IBOutlet weak var reviewStarsSlider: UISlider!
    @IBOutlet weak var reviewText: UITextView!
    
    var currentForeignUID: String?
    var ref: DatabaseReference!
    let uid = Auth.auth().currentUser?.uid
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        reviewText.becomeFirstResponder()
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveToDatabase)), animated: true)
        self.navigationItem.title = "Give Review"
        
        //sets the name
        ref.child("userInfo").child(uid!).child("Name").observeSingleEvent(of: .value, with: { (snapshot) in
            self.name = snapshot.value as? String
        }, withCancel: nil)
    }
    
    @objc func saveToDatabase() {
        
        let mainRef = ref.child("Reviews")
        let childRef = mainRef.childByAutoId()
        let toID = Shared.shared.currentForeignUid
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        let values = ["From": name!, "Text": reviewText.text, "Score": reviewStarsSlider.value, "Timestamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, mainRef) in
            if error != nil {
                print(error!)
                return
            }
            
            let messageId = childRef.key
            let recipientUserMessageRef = self.ref.child("user-reviews").child(toID)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}
