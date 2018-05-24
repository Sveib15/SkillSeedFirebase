//
//  ForeignReviewDisplayController.swift
//  HHR
//
//  Created by Anders Berntsen on 24.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit

class ForeignReviewDisplayController: UIViewController {
    
    @IBOutlet weak var giveReviewButton: UIButton!
    var foreignUid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        giveReviewButton.addTarget(self, action: #selector(segueToGiveReview), for: .touchUpInside)

    }
    @objc func segueToGiveReview() {
        foreignUid = Shared.shared.currentForeignUid
        let giveReviewController = GiveReviewController()
        giveReviewController.currentForeignUID = foreignUid
    }
    
    
}
