//
//  CustomTabBar.swift
//  HHR
//
//  Created by Anders Berntsen on 17.04.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit

class CustomTabBar: UITabBarController {
    
    
    var chosenIndex = Shared.shared.tabBarIndex
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = chosenIndex

        // Do any additional setup after loading the view.
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
