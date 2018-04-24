//
//  SearchTable.swift
//  HHR
//
//  Created by Anders Berntsen on 06.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase


class SearchTable: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref:DatabaseReference?
    var userNames = [String]() //Array
    let uid = Auth.auth().currentUser?.uid
    
    struct userList {
        var uid: String
        var distance: Double
        var imgUrl: String
        var avgRating: Double
        var ratingsCount: Int
        var name: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 100
        
        //Initial setup
        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        
        //Fills the name array from database
        let nameRef = ref?.child("userInfo").child(uid!).child("Name")
        nameRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let name = snapshot.value as? String
            if let downloadedName = name {
                self.userNames.append(downloadedName)
                self.tableView.reloadData()
            }
        })
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadArray)), animated: true)
    }
    
    @objc func reloadArray() {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Table View Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchProfileCell") as! SearchCell
        
        cell.nameLabel.text = userNames[indexPath.row]
        return cell
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
