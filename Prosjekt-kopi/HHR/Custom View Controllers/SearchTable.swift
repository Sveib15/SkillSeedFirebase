//
//  SearchTable.swift
//  HHR
//
//  Created by Anders Berntsen on 06.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GeoFire

class SearchTable: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var skillSortControl: UISegmentedControl!
    
    var ref: DatabaseReference!
    var GeoRef: GeoFire!
    var GeoTraineeRef: GeoFire!
    var users = [userList]()
    var distanceArray = [tempDistance]()
    let uid = Auth.auth().currentUser?.uid
    var dbPath: String = "Beginner"
    
    struct userList {
        var name: String?
        var databaseKey: String?
        var imageUrl: String?
        var distance: Double = 0
        var avgRating: Double?
        var ratingCount: Int?
    }
    
    struct tempDistance {
        var uid: String?
        var distanceToPrint: Double = 0
    }
    
    //Pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadArray), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.tableView.rowHeight = 100
        
        //Initial setup
        ref = Database.database().reference()
        GeoRef = GeoFire(firebaseRef: ref.child("Locations").child(dbPath))
        GeoTraineeRef = GeoFire(firebaseRef: ref.child("Locations").child("Trainee"))
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadArray)), animated: true)
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.darkGray
        
        skillSortControl.addTarget(self, action: #selector(changeGeoRef), for: .valueChanged)
        
        self.tableView.addSubview(self.refreshControl)
        fetchNearbyLocations(userID: uid!)
        
    } //end viewDidLoad

    func fetchNearbyLocations (userID: String) {
        
        var myLoc = CLLocation()
            (self.GeoTraineeRef.getLocationForKey(userID, withCallback: { (location, error) in
            if (error != nil) {
                
                print("An error occured in fetchNearbyLocations: \(String(describing: error?.localizedDescription))")
            }
            else if (location != nil) {
                myLoc = location!
                //sets the radius - at 100 km
                let circleQuery = self.GeoRef.query(at: myLoc, withRadius: 100.0)
            
                circleQuery.observe(.keyEntered, with: { (key: String, location: CLLocation!) in
                    let distanceFromUser = myLoc.distance(from: location)
                    if key == Auth.auth().currentUser?.uid {
                        print("crap")
                    }
                    else {
                    self.appendUserInfo(userKey: key, distanceToAppend: distanceFromUser)
                    }
                })
            }
        }))
    
    }
    
    func appendUserInfo (userKey: String, distanceToAppend: Double) {
        users = [userList]()
        checkName(userID: userKey) { (success) in
            if success {
                self.ref.child("userInfo").child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        self.users.append(userList.init(name: (dictionary["Name"] as! String), databaseKey: userKey, imageUrl: (dictionary["profileImage"] as! String), distance: distanceToAppend, avgRating: 0, ratingCount: 0))
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            } else {
                print("completion in appendUserInfo Failed")
            }
        }
    }
    
    
    //Reloads the arrays, acts as a refresh
    @objc func reloadArray() {

        self.fetchNearbyLocations(userID: self.uid!)
        print("=========================================")
        print("============ Array Prints ===============")
        print(self.users)
        print("=========================================")
        self.refreshControl.endRefreshing()
    }

    //sets the GeoRef to the needed value depending on the sorting
    @objc func changeGeoRef() {
        
        switch skillSortControl.selectedSegmentIndex {
        case 0:
            dbPath = "Beginner"
        case 1:
            dbPath = "Good"
        case 2:
            dbPath = "Adept"
        case 3:
            dbPath = "Elite"
        default:
            dbPath = "Beginner"
        }
        GeoRef = GeoFire(firebaseRef: ref.child("Locations").child(dbPath))
        reloadArray()
    }


    //CompletionBlock to check if the user has a userID
    func checkName(userID: String, completion: @escaping ((_ success: Bool) -> Void)){
        self.ref.child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
        
            if snapshot.hasChild(userID){
                completion(snapshot.hasChild(userID))
                //return true
            }else{
                print("DET FINNES INGEN USERDATA")
                completion(false)
                //return false
            }
            //return result
        }
    )}

    //completion block to check if user has any score, or rating
    func checkRatings(userID: String, completion: @escaping ((_ success: Bool) -> Void)){
        self.ref.child("avgScore").observeSingleEvent(of: .value, with: { (snapshot) in
        
            if snapshot.hasChild(userID){
                completion(snapshot.hasChild(userID))
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
    
    //Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchProfileCell") as! SearchCell
        
        cell.nameLabel.text = users[indexPath.row].name
        
        let distanceInKm = users[indexPath.row].distance / 1000
        let distanceStr = String(format: "%.1f", distanceInKm)
        cell.distanceLabel.text = "\(distanceStr) km"
    
        //sets the profile images to be round
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "showProfileSegue", sender: cell)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
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
