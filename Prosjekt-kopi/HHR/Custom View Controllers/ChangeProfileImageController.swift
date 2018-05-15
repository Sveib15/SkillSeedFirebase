//
//  ChangeProfileImageController.swift
//  HHR
//
//  Created by Anders Berntsen on 24.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class ChangeProfileImageController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var ref: DatabaseReference!
    let storageRef = Storage.storage().reference()
    
    @IBOutlet weak var profileImage: UIImageView!
    
    var selectedImageFromPicker: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveToDatabase)), animated: true)
        
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
        imageRef.observeSingleEvent(of: .value) { (snapshot) in
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
        
    } // End ViewDidLoad
    
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
    
    //IBAction continue
    @objc func saveToDatabase() {
        guard let uid = Auth.auth().currentUser?.uid
            else {
                return
        }
        
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
    Shared.shared.tabBarIndex = 3
    let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
    self.present(destinationController!, animated: true, completion: nil)
    } // End saveToDatabase()
    

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
