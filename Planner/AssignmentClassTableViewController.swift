//
//  AssignmentClassTableViewController.swift
//  Planner
//
//  Created by Christina Chau on 6/21/20.
//  Copyright © 2020 Christina Chau. All rights reserved.
//

import UIKit
import CoreData

class AssignmentClassTableViewController: UIViewController, NewAssignmenDelegate{
    func passInfo(assignTitle: String, desc: String, classes: String, dates: String) {
        self.assignTitle = title
        self.desc = desc
        self.classes = classes
        self.dates = dates
        self.save(assignmentTitle: assignTitle, assignmentDescription: desc, assignnmentClass: classes, assignmentDates: dates)
        updateAssignmentCount(className: classes, way: "add")
        populate()
    }
    
    func updateAssignmentCount(className: String, way: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Classes")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "classes") as? String == className{
                    var amt = data.value(forKey: "numberOfAssignments") as? Int
                    if way == "add"{
                        amt = amt! + 1
                    }
                    else{
                        amt = amt! - 1
                    }
                    data.setValue(amt!, forKey: "numberOfAssignments")
                }
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func save(assignmentTitle: String, assignmentDescription: String, assignnmentClass: String, assignmentDates: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Assignments", in: managedContext)!
        
        let assign = NSManagedObject(entity: entity, insertInto: managedContext)
        
        assign.setValue(assignmentTitle, forKeyPath: "assignmentTitle")
        assign.setValue(assignmentDescription, forKeyPath: "assignmentDesc")
        assign.setValue(assignnmentClass, forKeyPath: "classType")
        assign.setValue(assignmentDates, forKeyPath: "dueDate")
        
        do {
            try managedContext.save()
            assignment.append(assign)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "classAssignSeque"){
            let assignmentController = segue.destination as! NewAssignmentViewController
            assignmentController.delegate = self
        }
    }
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var className: String?
    
    private var assignTitle: String?
    private var desc: String?
    private var classes: String?
    private var dates: String?
    
    var assignment: [NSManagedObject] = []
    
    @IBOutlet var ClassAssign: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navTitle.title = className

    }
    
    override func viewDidAppear(_ animated: Bool) {
        populate()
        self.ClassAssign.reloadData()
    }
    
    func populate(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignments")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "classType") as? String == className{
                    assignment.append(data)
                }
            }
        } catch {
            print("Failed")
        }
    }
}

extension AssignmentClassTableViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let classAssign = assignment[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        let titleLbl = cell.viewWithTag(10) as! UILabel
            let classLbl = cell.viewWithTag(11) as! UILabel
            let descLbl = cell.viewWithTag(12) as! UILabel
            let dateLbl = cell.viewWithTag(13) as! UILabel
        
            titleLbl.text = classAssign.value(forKeyPath: "assignmentTitle") as? String
            descLbl.text = classAssign.value(forKeyPath: "assignmentDesc") as? String
            classLbl.text = classAssign.value(forKeyPath: "classType") as? String
            dateLbl.text = classAssign.value(forKeyPath: "dueDate") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let assign = assignment[indexPath.row]
            assignment.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignments")

            let assignmentTitle = assign.value(forKeyPath: "assignmentTitle") as? String
            let assignDesc = assign.value(forKeyPath: "assignmentDesc") as? String
            let assignClass = assign.value(forKeyPath: "classType") as? String
            let assignDate = assign.value(forKeyPath: "dueDate") as? String
            request.predicate = NSPredicate(format:"%K == %@ AND %K == %@ AND %K == %@ AND %K == %@", argumentArray:["assignmentTitle", assignmentTitle!, "assignmentDesc", assignDesc!,"classType",assignClass!,"dueDate",assignDate!])

            let result = try? context.fetch(request)
            let resultData = result as! [NSManagedObject]

            for object in resultData {
                context.delete(object)
            }
            updateAssignmentCount(className:assign.value(forKey: "classType") as! String,way:"minus")

            do {
                try context.save()
                populate()
                self.ClassAssign.reloadData()
            } catch {
                // add general error handle here
            }
        }
    }
    
    
}
