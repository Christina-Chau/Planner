//
//  TableViewController.swift
//  Planner
//
//  Created by Christina Chau on 6/18/20.
//  Copyright © 2020 Christina Chau. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController{

    private var classNames: [String] = []
    private let date = [["01","02","03","04","05","06","07","08","09","10","11","12"], ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]]
    private var toggle = false
        
    //Pickers
    
    @IBOutlet weak var classPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIPickerView!
    
    //Labels
    @IBOutlet weak var classLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateClassPicker()
        classPicker.dataSource = self
        classPicker.delegate = self
        datePicker.dataSource = self
        datePicker.delegate = self
        
    }
    
    func populateClassPicker(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Classes")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                classNames.append(data.value(forKey: "classes") as! String)
          }
            
        } catch {
            print("Failed")
        }
    }
    
//    override func tableView(_ tableView: UITableView,
//                            heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 1 && !toggle{
//            return 0
//        }
//        else if indexPath.row == 3 && !toggle{
//            return 0
//        }
//        else{
//            return super.tableView(tableView, heightForRowAt: indexPath)
//        }
//
//    }
//
//    override func tableView(_ tableView: UITableView,
//             didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        if (indexPath.row == 0 || indexPath.row == 2) && toggle{
//            toggle = true
//            tableView.beginUpdates()
//            tableView.endUpdates()
//            toggle = false
//        }
//    }
}

extension TableViewController: UIPickerViewDelegate, UIPickerViewDataSource{

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == classPicker{
            return 1
        }
        else{
            return 2
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == classPicker{
            return classNames.count
        }
        else{
            return date[component].count
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == classPicker{
            classLbl.text = classNames[row]
        }
        else{
            let month = date[0][datePicker.selectedRow(inComponent: 0)]
            let day = date[1][datePicker.selectedRow(inComponent: 1)]
            dateLbl.text = month + "/" + day

        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == classPicker {
            return classNames[row]

        }
        else{
            return date[component][row]
        }
    }
}
