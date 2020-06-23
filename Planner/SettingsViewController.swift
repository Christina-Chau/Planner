//
//  SettingsViewController.swift
//  Planner
//
//  Created by Christina Chau on 6/22/20.
//  ID: 112720104
//  Copyright © 2020 Christina Chau. All rights reserved.
//

import UIKit
import CoreData

protocol SettingsDelegate: class{
    func passSettings(sort: String, order: String)
}

class SettingsViewController: UIViewController{

    private var sort = ["Class","Assignment","Date"]
    private var order = ["Ascending","Descending"]
    
    var sortStr: String?
    var orderStr: String?
    
    weak var delegate: SettingsDelegate?
    
    @IBOutlet weak var orderLbl: UILabel!
    @IBOutlet weak var sortLbl: UILabel!
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet weak var orderPicker: UIPickerView!
    
    
    @IBAction func saveChanges(_ sender: UIButton) {
        sortStr = String(sortLbl.text!)
        orderStr = String(orderLbl.text!)
        self.delegate?.passSettings(sort: sortStr!, order: orderStr!)
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
            sortLbl.text = sort[row]
        }
        else{
            orderLbl.text = order[row]

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
