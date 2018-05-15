//
//  RegistrationController.swift
//  HHR
//
//  Created by Anders Berntsen on 10.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseStorage

class RegistrationController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    var uploadDesc : String = ""
    var uploadSkill: Int = 0
    var selectedImageFromPicker: UIImage?
    var userName: String = "Thread 1 SIGBERT"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        //sets the welcome Label to display correct name
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "first_name, name"]).start {
            (connection, result, err) in
            
            guard let data = result as? [String: Any] else {return}
            let name = data["first_name"]
            self.userName = data["name"] as! String
        
            if err != nil {
                print("problem:", err ?? "")
                return
            }
            self.welcomeLabel.text = ("Welcome \(name! )")
        }
        //Sets the image as a circle
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        profileImage.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func handleSelectImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //Selects and stores the image in a local variable
        if let editedImage = info["UIImagePickerControllerEditedImage"]
        as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func Continue(_ sender: Any) {
        //Gets the user ID for the current user
        guard let uid = Auth.auth().currentUser?.uid
            else {
                return
        }
        checkDescription(userID: uid, completion: { (success) -> Void in
            if success{
                let skillValues = ["Skill": self.uploadSkill] as [String : Any]
                self.ref?.child("userSkillGolf").child(uid).updateChildValues(skillValues, withCompletionBlock: {(err, ref) in
                    //Errorhandling
                    if err != nil {
                        print(err!)
                        return
                    }
                })
                let nameValue = ["Name": self.userName] as [String : Any]
                self.ref?.child("userInfo").child(uid).updateChildValues(nameValue, withCompletionBlock: {(err, ref) in
                    //Errorhandling
                    if err != nil {
                        print(err!)
                        return
                    }
                })
                print("SUCCESSFULLY PUSHED TO DATABASE with your chosen desc")
            } else{
                //Pushes info to database
                let descValues = ["Name": self.userName, "Description": ""] as [String : Any]
                self.ref?.child("userInfo").child(uid).updateChildValues(descValues, withCompletionBlock: {(err, ref) in
                    //Errorhandling
                    if err != nil {
                        print(err!)
                        return
                    }
                })
                let skillValues = ["Skill": self.uploadSkill] as [String : Any]
                self.ref?.child("userSkillGolf").child(uid).updateChildValues(skillValues, withCompletionBlock: {(err, ref) in
                    //Errorhandling
                    if err != nil {
                        print(err!)
                        return
                    }
                })
                print("SUCCESSFULLY PUSHED TO DATABASE with blank desc")
            }
        })
        //Uploads image to the storage
        let imageName = NSUUID().uuidString
        let profileImageRef = storageRef.child("\(imageName).png")
        
        if let uploadImage = UIImageJPEGRepresentation(self.profileImage.image!, 0.07) {
            profileImageRef.putData(uploadImage, metadata: nil, completion: {
                (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["profileImage" : profileImageUrl]
                    self.ref.child("userInfo").child(uid).updateChildValues(values, withCompletionBlock: {(err, ref) in
                        //Errorhandling
                        if err != nil {
                            print(err!)
                            return
                        }
                    })
                }
            }) // end putdata
        }
        Shared.shared.tabBarIndex = 0
        let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
        self.present(destinationController!, animated: true, completion: nil)
    }//end continue
    
    @IBAction func SelectedSkill(_ sender: CustomSegmentControl) {
        uploadSkill = sender.selectedSegmentIndex
        print(uploadSkill)
    }
    
    func checkDescription(userID: String, completion: @escaping ((_ success: Bool) -> Void)){
        self.ref.child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            //var result: Bool
            
            if snapshot.hasChild(userID){
                print("DU HAR SATT OPP DESCRIPTION!")
                completion(snapshot.hasChild(userID))
                //return true
            }else{
                print("DU HAR IKKE SATT OPP DESCRIPTION, DEN BLE SATT TIL INGENTING")
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
