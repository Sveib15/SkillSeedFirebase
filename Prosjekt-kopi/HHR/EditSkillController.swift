//
//  EditSkillController.swift
//  HHR
//
//  Created by Anders Berntsen on 18.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class EditSkillController: UIViewController {
    
    @IBOutlet weak var SkillSelector: CustomSegmentControl!
    var ref: DatabaseReference!
    var uploadSkill: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(composeSkill)), animated: true)
        
        ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        let skillRef = ref.child("userInfo").child(uid!).child("Skill")
        skillRef.observeSingleEvent(of: .value) { (snapshot) in
            self.SkillSelector.updateView(index: (snapshot.value as? Int)!)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SelectedSkill(_ sender: CustomSegmentControl) {
        uploadSkill = sender.selectedSegmentIndex
        print(uploadSkill)
    }
    
    @objc func composeSkill() {
        guard let uid = Auth.auth().currentUser?.uid
            else {
                return
        }
        let values = ["Skill": self.uploadSkill] as [String : Any]
        self.ref?.child("userInfo").child(uid).updateChildValues(values, withCompletionBlock: {(err, ref) in
            //Errorhandling
            if err != nil {
                print(err!)
                return
            }
        })
        print("SUCCESSFULLY PUSHED TO DATABASE")
        Shared.shared.tabBarIndex = 3
        let RegController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
        self.present(RegController!, animated: true, completion: nil)
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
