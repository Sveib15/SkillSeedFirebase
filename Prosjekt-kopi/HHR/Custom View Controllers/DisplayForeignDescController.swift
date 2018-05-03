//
//  DisplayDescController.swift
//  HHR
//
//  Created by Anders Berntsen on 23.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class DisplayForeignDescController: UIViewController {
    
    var ref: DatabaseReference!
    var foreignUid: String = Shared.shared.currentForeignUid
    @IBOutlet weak var DisplayDesc: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        let descRef = ref.child("userInfo").child(foreignUid).child("Description")
        descRef.observeSingleEvent(of: .value) { (snapshot) in
            self.DisplayDesc.text = snapshot.value as? String
        }
        
        
        // Do any additional setup after loading the view.
    }
    
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

