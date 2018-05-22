//
//  CalendarVC.swift
//  HHR
//
//  Created by Anders Berntsen on 13.02.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//
//


import UIKit

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.layer.masksToBounds = true
        calendarView.layer.cornerRadius = 20
    }
    
    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
