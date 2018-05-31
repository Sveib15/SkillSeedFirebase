//
//  ForeignProfileController.swift
//  HHR
//
//  Created by Anders Berntsen on 03.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class ForeignProfileController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var skillDisplay: UIButton!
    
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
        
        checkRatings(userID: foreignUid!, BranchToCheck: "avgScore") { (success) in
            if success {
                let ratingRef = self.ref.child("userInfo").child(self.foreignUid!)
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
        let skillRef = ref.child("userSkillGolf").child(foreignUid!).child("Skill")
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
                
    } // End ViewDidLoad
    
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
    
    
    @IBAction func segueToChat(_ sender: Any) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.navigationItem.title = nameLabel.text
        chatLogController.currentForeignUID = foreignUid
        
        navigationController?.pushViewController(chatLogController, animated: true)
    }
}
