//
//  SettingsViewController.swift
//  Planner
//
//  Created by Christina Chau on 6/22/20.
//  Copyright © 2020 Christina Chau. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController{

    private var sort = ["Class","Assignment","Date"]
    private var order = ["Ascending","Descending"]
    
    private var sortStr: String?
    private var orderStr: String?
    
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet weak var orderPicker: UIPickerView!
    

    @IBAction func saveChanges(_ sender: UIButton) {
        sortAssignmentTable()
        //sortClassesTable()
    }
    
    func sortAssignmentTable(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let managedContext = managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignments")
        var sortDescriptor: NSSortDescriptor
        if sortStr == "Class"{
            if orderStr == "Ascending"{
                sortDescriptor = NSSortDescriptor(key: "classType", ascending: true)
            }
            else{
                sortDescriptor = NSSortDescriptor(key: "classType", ascending: false)
            }
        }
        else if sortStr == "Assignment"{
            if orderStr == "Ascending"{
                sortDescriptor = NSSortDescriptor(key: "assignmentTitle", ascending: true)
            }
            else{
                sortDescriptor = NSSortDescriptor(key: "assignmentTitle", ascending: false)
            }
        }
        else{
            if orderStr == "Ascending"{
                sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
            }
            else{
                sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: false)
            }
        }
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            _ = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func sortClassesTable(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortPicker.dataSource = self
        sortPicker.delegate = self
        orderPicker.dataSource = self
        orderPicker.delegate = self
    }
    
}
extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sortPicker{
            return sort.count
        }
        else{
            return order.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sortPicker{
            sortStr = sort[row]
        }
        else{
            orderStr = order[row]

        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == sortPicker {
            return sort[row]

        }
        else{
            return order[row]
        }
    }
}
