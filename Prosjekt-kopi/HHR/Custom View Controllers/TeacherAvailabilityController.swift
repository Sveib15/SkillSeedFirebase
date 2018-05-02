//
//  TeacherAvailabilityController.swift
//  HHR
//
//  Created by Anders Berntsen on 24.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreLocation

class TeacherAvailabilityController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var skillSelector: CustomSegmentControl!
    @IBOutlet weak var deleteMeButton: UIButton!
    
    var ref: DatabaseReference!
    var GeoRef: GeoFire!
    var locationManager = CLLocationManager()
    var selectedSkill = 0
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveToDatabase)), animated: true)
        
        ref = Database.database().reference()
        GeoRef = GeoFire(firebaseRef: ref.child("Locations"))
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        deleteMeButton.layer.masksToBounds = false
        deleteMeButton.layer.cornerRadius = deleteMeButton.frame.height/2
        deleteMeButton.clipsToBounds = true
        
        deleteMeButton.addTarget(self, action: #selector(deleteFromDatabase), for: .touchUpInside)
    }// End viewDidLoad
    
    func setMyLocation(userId: String, dbBranch: GeoFire){
        
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            currentLocation = locationManager.location
            print("FØRSTE SHID + \(currentLocation.coordinate.latitude) + HER ER DEN ANDRE SHIDEN + \(currentLocation.coordinate.longitude) ")
            
            
            dbBranch.setLocation(CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), forKey: userId) { (error) in
                if (error != nil) {
                    print("An error occured: \(error ?? "" as! Error)")
                } else {
                    print("Saved location successfully!")
                }//end if errorhandler
            }//end GeoRef
        }//end if
    }//end setMyLocation
    
    @objc func saveToDatabase() {
        
        guard let uid = Auth.auth().currentUser?.uid
            else {
                return
        }
        let beginnerRef = GeoFire(firebaseRef: ref.child("Locations").child("Beginner"))
        let goodRef = GeoFire(firebaseRef: ref.child("Locations").child("Good"))
        let adeptRef = GeoFire(firebaseRef: ref.child("Locations").child("Adept"))
        let eliteRef = GeoFire(firebaseRef: ref.child("Locations").child("Elite"))
        
        switch selectedSkill {
        case 0:
            setMyLocation(userId: uid, dbBranch: beginnerRef)
        case 1:
            setMyLocation(userId: uid, dbBranch: goodRef)
        case 2:
            setMyLocation(userId: uid, dbBranch: adeptRef)
        case 3:
            setMyLocation(userId: uid, dbBranch: eliteRef)
        default:
            print("Whoops 1 - default i switchen")
            return
        }
        Shared.shared.tabBarIndex = 3
        let RegController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
        self.present(RegController!, animated: true, completion: nil)
    }
    
    @IBAction func skillChanged(_ sender: CustomSegmentControl) {
        selectedSkill = sender.selectedSegmentIndex
    }
    
    @objc func deleteFromDatabase() {
        
        let refreshAlert = UIAlertController(title: "Delete your Location?", message: "Do you really want to be deleted?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            if Auth.auth().currentUser != nil {
                do {
                    let beginnerRef = GeoFire(firebaseRef: self.ref.child("Locations").child("Beginner"))
                    let goodRef = GeoFire(firebaseRef: self.ref.child("Locations").child("Good"))
                    let adeptRef = GeoFire(firebaseRef: self.ref.child("Locations").child("Adept"))
                    let eliteRef = GeoFire(firebaseRef: self.ref.child("Locations").child("Elite"))
                    
                    beginnerRef.removeKey(self.uid!)
                    goodRef.removeKey(self.uid!)
                    adeptRef.removeKey(self.uid!)
                    eliteRef.removeKey(self.uid!)
                }
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Nothing Happened")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
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
