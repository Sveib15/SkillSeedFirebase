//
//  InitialDescView.swift
//  HHR
//
//  Created by Anders Berntsen on 10.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class InitialDescView: UIViewController, UITextViewDelegate {
    
    var ref: DatabaseReference!

    @IBOutlet weak var descEdited: UITextView!
    @IBOutlet weak var wordCounter: UILabel!
    var initialDesc : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        self.descEdited.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDescLenght(text: String, length: Int) -> Bool {
        if text.count <= length {
            return true
        } else {
            return false
        }
    }
    
    //saves, and dismisses the view
    @IBAction func descDone(_ sender: Any) {
        initialDesc = descEdited.text
        
        //Gets the user ID for the current user
        guard let uid = Auth.auth().currentUser?.uid
            else {
                return
        }
        if checkDescLenght(text: initialDesc, length: 500) {
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
        } else {
            let alert = UIAlertController(title: "Too long description", message: "Your description needs to be 500 characters or less.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    //TextView functions
    func checkRemainingChars() {
        let charsInText = descEdited.text.count
        wordCounter.text = "\(charsInText)/500"
        
        if charsInText > 500 {
            wordCounter.textColor = UIColor.red
        } else {
            wordCounter.textColor = UIColor.lightGray

        }

    }
    func textViewDidChange(_ textView: UITextView) {
        checkRemainingChars()
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
