//
//  MyProfileController.swift
//  HHR
//
//  Created by Anders Berntsen on 15.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class MyProfileController: UIViewController{

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var skillDisplay: UIButton!
    
    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()
    
    var container: ContainerViewController!

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
        //Sets the correct name label
        let descRef = ref.child("userInfo").child(uid).child("Name")
        descRef.observeSingleEvent(of: .value) { (snapshot) in
            self.nameLabel.text = snapshot.value as? String
        }
        
        checkRatings(userID: uid, BranchToCheck: "avgScore") { (success) in
            if success {
                let ratingRef = self.ref.child("userInfo").child(uid)
                ratingRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    let dictionary = snapshot.value as! [String: AnyObject]
                    self.cosmosView.rating = dictionary["avgScore"] as! Double
                    self.cosmosView.text = "(\(dictionary["ratingCount"] as! Int))"
                    
                }, withCancel: nil)
            } else {
                self.cosmosView.rating = 0
                self.cosmosView.text = "(0)"
            }
        }
        
        //sets the skill Value
        let skillRef = ref.child("userSkillGolf").child(uid).child("Skill")
        skillRef.observeSingleEvent(of: .value) { (snapshot) in
            
            self.skillDisplay.isUserInteractionEnabled = false
            self.skillDisplay.layer.masksToBounds = true
            self.skillDisplay.layer.cornerRadius = 20
            
            switch snapshot.value as! Int {
            case 0:
                self.skillDisplay.setTitle("Beginner", for: .normal)
            case 1:
                self.skillDisplay.setTitle("Good", for: .normal)
            case 2:
                self.skillDisplay.setTitle("Adept", for: .normal)
            case 3:
                self.skillDisplay.setTitle("Elite", for: .normal)
            default:
                self.skillDisplay.setTitle("Beginner", for: .normal)
            }
        }
        //Sets the container view to show description
        container.segueIdentifierReceivedFromParent("Description")
        
    }//end viewDidLoad
    
    //stuff to set up the embedded views of reviews, and description
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "container" {
            self.container = segue.destination as! ContainerViewController
        }
    }
    
    func checkRatings(userID: String, BranchToCheck: String, completion: @escaping ((_ success: Bool) -> Void)){
        self.ref.child("userInfo").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(BranchToCheck){
                completion(snapshot.hasChild(BranchToCheck))
                print("Ratingdata finnes")
                //return true
            }else{
                print("DET FINNES INGEN RATINGDATA, Setter alt til 0!")
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
        
    
    @IBAction func changeContainerView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            container.segueIdentifierReceivedFromParent("Description")
        }
        else {
            container.segueIdentifierReceivedFromParent("Review")
        }
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
