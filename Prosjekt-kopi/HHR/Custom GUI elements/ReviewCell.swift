//
//  ReviewCell.swift
//  HHR
//
//  Created by Anders Berntsen on 24.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Cosmos

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var reviewText: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
