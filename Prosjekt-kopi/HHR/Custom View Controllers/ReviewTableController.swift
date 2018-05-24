//
//  ReviewTableController.swift
//  HHR
//
//  Created by Anders Berntsen on 24.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit

class ReviewTableController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoResultsCell")
        return cell!
    }
}
