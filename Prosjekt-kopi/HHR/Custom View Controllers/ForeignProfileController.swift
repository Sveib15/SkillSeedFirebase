//
//  ForeignProfileController.swift
//  HHR
//
//  Created by Anders Berntsen on 03.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class ForeignProfileController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var skillSelector: CustomSegmentControl!
    
    var foreignUid: String?
    var container: ContainerViewController!
    
    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Shared.shared.currentForeignUid = foreignUid!
        ref = Database.database().reference()
        
        //Sets the image as a circle
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        //Sets image
        let imageRef = ref.child("userInfo").child(foreignUid!).child("profileImage")
        imageRef.observe(DataEventType.value) { (snapshot) in
            let imageUrlString = snapshot.value as? String
            //Her må vi sjekke om det ligger noe. hvis ikke crasher vi!
            let imageUrl = URL(string: imageUrlString!)
            setImage(imgURL: imageUrl!)
        }
        func setImage (imgURL: URL) {
            let networkService = NetworkService(url: imgURL)
            networkService.downloadImage { (data) in
                let image = UIImage(data: data as Data)
                DispatchQueue.main.async {
                    self.profileImage.image = image
                }
            }
        }
        
        //Sets the correct name label, and title
        let nameRef = ref.child("userInfo").child(foreignUid!).child("Name")
        nameRef.observeSingleEvent(of: .value) { (snapshot) in
            self.nameLabel.text = snapshot.value as? String
            self.title = snapshot.value as? String
        }
        
        //sets the skill Value
        let skillRef = ref.child("userSkillGolf").child(foreignUid!).child("Skill")
        skillRef.observeSingleEvent(of: .value) { (snapshot) in
            self.skillSelector.updateView(index: (snapshot.value as? Int)!)
        }
        //Sets the container view to show description
        container.segueIdentifierReceivedFromParent("Description")
        
    } // End ViewDidLoad

    
    //ContainerView functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container" {
            
            self.container = segue.destination as! ContainerViewController
        }
    }
    
    @IBAction func changeContainerIndex(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            container.segueIdentifierReceivedFromParent("Description")
        }
        else {
            container.segueIdentifierReceivedFromParent("Review")
        }
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
