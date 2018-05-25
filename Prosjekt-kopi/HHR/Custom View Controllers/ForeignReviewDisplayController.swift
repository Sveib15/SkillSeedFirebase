//
//  ForeignReviewDisplayController.swift
//  HHR
//
//  Created by Anders Berntsen on 24.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class ForeignReviewDisplayController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    struct Review {
        var text: String?
        var score: Double?
        var name: String?
    }
    
    var reviewArray = [Review]()
    var ref: DatabaseReference!
    var foreignUid = Shared.shared.currentForeignUid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 100
        
        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchReviews()
    }
    
    func fetchReviews() {
        let userReviewRef = ref.child("user-reviews").child(foreignUid)
        userReviewRef.observe(.childAdded, with: { (snapshot) in
            
            let reviewID = snapshot.key
            let reviewRef = self.ref.child("Reviews").child(reviewID)
            
            reviewRef.observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String: AnyObject]
                let reviews = Review.init(text: (dictionary!["Text"] as! String), score: (dictionary!["Score"] as! Double), name: (dictionary!["From"] as! String))
                self.reviewArray.append(reviews)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewCell
        
        let review = reviewArray[indexPath.row]
        
        cell.nameLabel.text = review.name
        cell.reviewText.text = review.text
        cell.reviewScoreLabel.text = String(format: "%.1f", review.score!)
        
        return cell
    }
    
    @objc func segueToGiveReview() {
        foreignUid = Shared.shared.currentForeignUid
        let giveReviewController = GiveReviewController()
        giveReviewController.currentForeignUID = foreignUid
    }
   
}
