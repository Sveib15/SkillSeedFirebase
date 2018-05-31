//
//  GiveReviewController.swift
//  HHR
//
//  Created by Anders Berntsen on 24.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class GiveReviewController: UIViewController {

    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var cosmosView: CosmosView!
    
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
        let score = cosmosView.rating
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        let values = ["From": name!, "Text": reviewText.text, "Score": (score + 1), "Timestamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, mainRef) in
            if error != nil {
                print(error!)
                return
            }
            
            let messageId = childRef.key
            let recipientUserMessageRef = self.ref.child("user-reviews").child(toID)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        
        checkFirstTime { (success) in
            if success {
                self.setAvgScore()
            } else {
                self.ref.child("userInfo").child(toID).updateChildValues(["avgScore": score, "ratingCount": 1])
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func setAvgScore() {
        let foreignUID = Shared.shared.currentForeignUid
        let score = cosmosView.rating
        let scoreRef = ref.child("userInfo").child(foreignUID)
        //sets the average score
        
        scoreRef.child("avgScore").observeSingleEvent(of: .value, with: { (snapshot) in
            let avgScore = snapshot.value as! Double
            
            self.ref.child("user-reviews").child(foreignUID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dictionary = snapshot.value as! [String: AnyObject]
                let reviewCount = Double(dictionary.count)
                
                let avgScoreTimesCount = (avgScore * reviewCount)
                let scoreToPost = (avgScoreTimesCount + (score + 1)) / (reviewCount + 1)
                
                self.ref.child("userInfo").child(foreignUID).updateChildValues(["avgScore": (scoreToPost), "ratingCount": Int(reviewCount + 1)])
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func checkFirstTime(completion: @escaping ((_ success: Bool) -> Void)){
        let foreignUID = Shared.shared.currentForeignUid
        
        self.ref.child("userInfo").child(foreignUID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild("avgScore"){
                completion(true)
                //return true
            }else{
                print("avgScore finnes ikke, første sending")
                completion(false)
            }
            //return result
        }
        )}
}
