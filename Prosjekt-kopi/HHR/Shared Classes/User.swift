//
//  User.swift
//  HHR
//
//  Created by Bjørn Erik Vik Olsen on 17.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class User {
    var name: String
    var firstName: String
    var lastName: String
    var profileImage: String
    var description: String
    var skillValue: Int
    var CERT1: Bool
    var CERT2: Bool
    var CERT3: Bool
    var PGA: Bool
    //var DictCert:[(nameCert:String, valueCert:Bool)] = []
    var DictCert = ["CERT1": false, "CERT2": false, "CERT3": false, "PGA": false]
    var avgScore: Double
    var listReview = [Review]()
    
    
    init(name: String, firstName: String, lastName: String, profileImage: String, description: String, skillValue: Int, CERT1: Bool, CERT2: Bool, CERT3: Bool, PGA: Bool, avgScore: Double){
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.profileImage = profileImage
        self.description = description
        self.skillValue = skillValue
        self.CERT1 = CERT1
        self.CERT2 = CERT2
        self.CERT3 = CERT3
        self.PGA = PGA
        self.avgScore = avgScore
        self.listReview = []
        
    }
    //Retrieve name from FB
    /*
     func getName() -> String {
     
     FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "first_name, last_name, name"]).start {
     (connection, result, err) in
     
     guard let data = result as? [String:Any] else {return}
     let name = data["name"]
     let firstName = data["first_name"]
     let lastName = data["last_name"]
     
     if err != nil {
     print("problem:", err ?? "")
     return
     }
     }
     return name
     }
     */
    
    //Retrieve name (full name)from database
    func getName() -> String {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("userInfo").child(uid!).child("Name").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let name = snapshot.value as? String {
                //Do not cast print it directly may be score is Int not string
                print("Printer navn: \(name)")
            }
            
        }, withCancel: nil
            
        )
        return name
    }
    
    //Retrieve firstname from database
    func getFirstName() -> String{
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("userInfo").child(uid!).child("firstName").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let firstName = snapshot.value as? String {
                //Do not cast print it directly may be score is Int not string
                print(firstName)
            }
            
        }, withCancel: nil
            
        )
        return firstName
    }
    
    //Retrieve description from database
    func getDescription() -> String {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("userInfo").child(uid!).child("Description").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let description = snapshot.value as? String {
                //Do not cast print it directly may be score is Int not string
                print(description)
            }
            
        }, withCancel: nil
            
        )
        return description
    }
    
    //Retrieve skillvalue from database
    func getSkillValue() -> Int {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("userSkillGolf").child(uid!).child("Skill").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let skillValue = snapshot.value as? Int {
                //Do not cast print it directly may be score is Int not string
                print(skillValue)
            }
            
        }, withCancel: nil
            
        )
        return skillValue
    }
    
    //Retrieve certification 1 (CERT1) from database
    func getCert1() -> Bool {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Cert").child(uid!).child("CERT2").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let CERT1 = snapshot.value as? Bool {
                //Do not cast print it directly may be score is Int not string
                print(CERT1)
            }
            
        }, withCancel: nil
            
        )
        return CERT1
    }
    
    //Retrieve certification 2 (CERT2) from database
    func getCert2() -> Bool {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Cert").child(uid!).child("CERT2").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let CERT2 = snapshot.value as? Bool {
                //Do not cast print it directly may be score is Int not string
                print(CERT2)
            }
            
        }, withCancel: nil
            
        )
        return CERT2
    }
    
    //Retrieve certification 3 (CERT3) from database
    func getCert3() -> Bool {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Cert").child(uid!).child("CERT3").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let CERT3 = snapshot.value as? Bool {
                //Do not cast print it directly may be score is Int not string
                print(CERT3)
            }
            
        }, withCancel: nil
            
        )
        return CERT3
    }
    
    //Retrieve certification 4 (PGA) from database
    func getPGA() -> Bool {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("Cert").child(uid!).child("PGA").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let PGA = snapshot.value as? Bool {
                //Do not cast print it directly may be score is Int not string
                print(PGA)
            }
            
        }, withCancel: nil
            
        )
        return PGA
    }
    
    //Retrieve average score from database
    func getAvgScore() -> Double {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("avg_Score").child(uid!).child("avgScore").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let avgScore = snapshot.value as? Double {
                //Do not cast print it directly may be score is Int not string
                print(avgScore)
            }
            
        }, withCancel: nil
            
        )
        return avgScore
    }
    
    //Retrieve profilepicture from database
    func getProfilePicture() -> String {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("userInfo").child(uid!).child("profileImage").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let profileImage = snapshot.value as? String {
                //Do not cast print it directly may be score is Int not string
                print(profileImage)
            }
            
        }, withCancel: nil
            
        )
        return profileImage
    }
    
    //Retrieve review from database
    func getReview() -> Array<Any> {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("userInfo").child(uid!).observe(.childAdded, with: {(snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let review = Review()
                review.setValuesForKeys(dictionary)
                self.listReview.append(review)
                print(review.text!, review.rating!)
            }
        }, withCancel: nil
            
        )
        return listReview
    }
    
    func getAllCert(DictCert: [String: Bool]) -> Dictionary<String, Bool> {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("userInfo").child(uid!).observe(.childAdded, with: {(snapshot) in
            
            let dict = snapshot.value as! [String: Any]
            let CERT1 = dict["CERT1"] as! Bool
            let CERT2 = dict["CERT2"] as! Bool
            let CERT3 = dict["CERT3"] as! Bool
            let PGA = dict["PGA"] as! Bool
            
            self.DictCert.updateValue(CERT1, forKey: "CERT1")
            self.DictCert.updateValue(CERT2, forKey: "CERT2")
            self.DictCert.updateValue(CERT3, forKey: "CERT3")
            self.DictCert.updateValue(PGA, forKey: "PGA")
        }
            
        )
        return DictCert
    }
    
    
}
//Class review
class Review: NSObject {
    var text: String?
    var rating: Double?
    
}
