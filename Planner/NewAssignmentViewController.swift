//
//  NewAssignmentViewController.swift
//  Planner
//
//  Created by Christina Chau on 6/16/20.
//  ID: 112720104
//  Copyright © 2020 Christina Chau. All rights reserved.
//

import UIKit

protocol NewAssignmenDelegate: class{
    func passInfo(assignTitle: String, desc: String, classes: String, dates: String)
}

class NewAssignmentViewController: UIViewController{
    
    var tableView: TableViewController?
    weak var delegate: NewAssignmenDelegate?
    private var assignTitle: String?
    private var assignDesc: String?
    private var classes: String?
    private var dates: String?
    //Text Fields
  
    @IBOutlet weak var titleName: UITextField!
    @IBOutlet weak var desc: UITextField!
    
    
    //Buttons
    @IBAction func done(_ sender: UIButton) {
        if titleName.text!.count > 0{
            assignTitle = titleName.text
            if desc.text!.count > 0{
                assignDesc = desc.text
            }
            else{
                assignDesc = "none"
            }
            classes = tableView?.classLbl.text
            dates = tableView?.dateLbl.text
            if dates == "00/00"{
                let alertController = UIAlertController(title: "Alert", message:
                    "Date cannot be 00/00", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

                self.present(alertController, animated: true, completion: nil)
            }
            else{
                self.delegate?.passInfo(assignTitle: assignTitle!, desc: assignDesc!, classes: classes!, dates: dates!)
                self.dismiss(animated: true, completion: nil)
            }
            
            
        }
        else{
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        guard let tableController = children.first as? TableViewController else {fatalError("Check storyboard for missing TableViewController")}
        tableView = tableController

    }
    
}

