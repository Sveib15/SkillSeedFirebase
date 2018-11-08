//
//  CategoriesController.swift
//  HHR
//
//  Created by Anders Berntsen on 25/10/2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit

class CategoriesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var categoryArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        
        initiateArray()
    }
    
    func initiateArray() {
        categoryArray.append("Golf")
        categoryArray.append("Tennis")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Categories") as! CategoryCell
        
        Shared.shared.currentCategory = cell.CategoryName.text!
        Shared.shared.tabBarIndex = 1
        let RegController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
        self.present(RegController!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Categories") as! CategoryCell
        
        cell.CategoryName.text = categoryArray[indexPath.row]
        
        return cell
    }
}
