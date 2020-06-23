//
//  AssignmentsTableViewController.swift
//  Planner
//
//  Created by Christina Chau on 6/20/20.
//  ID: 112720104
//  Copyright © 2020 Christina Chau. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class AssignmentsTableViewController: UIViewController, NewAssignmenDelegate, SettingsDelegate {
    
    private var assignTitle: String?
    private var desc: String?
    private var classes: String?
    private var dates: String?
    private var sort: String?
    private var order: String?
    
    var editObj: NSManagedObject?
    var sortStr: String?
    var orderStr: String?
    
    var assignment: [NSManagedObject] = []
    
    @IBOutlet var assignTableView: UITableView!
    
    func passSettings(sort: String, order: String){
        print(sort)
        self.sort = sort
        self.order = order
        settings()
    }
    
    func settings(){
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
         self.assignTableView.reloadData()
    }
    
    func passInfo(assignTitle: String, desc: String, classes: String, dates: String) {
        self.assignTitle = title
        self.desc = desc
        self.classes = classes
        self.dates = dates
        self.save(assignmentTitle: assignTitle, assignmentDescription: desc, assignnmentClass: classes, assignmentDates: dates)
        updateAssignmentCount(className: classes, way: "add")
        self.assignTableView.reloadData()
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
        if(segue.identifier == "segueNewAssignment"){
            let assignmentController = segue.destination as! NewAssignmentViewController
            assignmentController.delegate = self
        }
        
        if(segue.identifier == "settingsSegue"){
            let settingsController = segue.destination as! SettingsViewController
            settingsController.delegate = self
        }
    }
    
    func numberAssignments() ->Int{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignments")
        request.returnsObjectsAsFaults = false
        var count = 0
        do {
            let result = try context.fetch(request)
            for _ in result as! [NSManagedObject] {
                count = count + 1
            }
            
        } catch {
            print("Failed")
        }
        return count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let badgeCount: Int = numberAssignments()
            let application = UIApplication.shared
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            }
            application.registerForRemoteNotifications()
            application.applicationIconBadgeNumber = badgeCount
    }
    
    override func viewWillAppear(_ animated: Bool){
            super.viewWillAppear(animated)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Assignments")

        do {
            assignment = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.assignTableView.reloadData()
    }
}

extension AssignmentsTableViewController: UITableViewDataSource, UITableViewDelegate {
    
  func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return assignment.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currAssignment = assignment[indexPath.row]
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath)
        let titleLbl = cell.viewWithTag(10) as! UILabel
        let classLbl = cell.viewWithTag(11) as! UILabel
        let descLbl = cell.viewWithTag(12) as! UILabel
        let dateLbl = cell.viewWithTag(13) as! UILabel
    
        titleLbl.text = currAssignment.value(forKeyPath: "assignmentTitle") as? String
        descLbl.text = currAssignment.value(forKeyPath: "assignmentDesc") as? String
        classLbl.text = currAssignment.value(forKeyPath: "classType") as? String
        dateLbl.text = currAssignment.value(forKeyPath: "dueDate") as? String
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
                
                self.assignTableView.reloadData()
            } catch {
                // add general error handle here
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath:IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
