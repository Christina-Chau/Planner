//
//  ClassTableViewController.swift
//  Planner
//
//  Created by Christina Chau on 6/19/20.
//  Copyright © 2020 Christina Chau. All rights reserved.
//

import UIKit
import CoreData

class ClassTableViewController: UIViewController {
    
    var classes: [NSManagedObject] = []
    @IBOutlet var tableView: UITableView!
    
    @IBAction func addClass(_ sender: UIButton) {
        let alert = UIAlertController(title: "New Class", message: "Add a new class", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
          [unowned self] action in
          
            guard let textField = alert.textFields?.first,
                let classToSave = textField.text else {
              return
            }
            self.save(className: classToSave, num: 0)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(className: String, num: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
      
        let managedContext = appDelegate.persistentContainer.viewContext
    
        let entity = NSEntityDescription.entity(forEntityName: "Classes", in: managedContext)!
      
        let classLbl = NSManagedObject(entity: entity, insertInto: managedContext)
      
        classLbl.setValue(className, forKeyPath: "classes")
        classLbl.setValue(num, forKeyPath: "numberOfAssignments")
      
        do {
            try managedContext.save()
            classes.append(classLbl)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Classes")
      
        do {
            classes = try managedContext.fetch(fetchRequest)
            self.tableView.reloadData()
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}

extension ClassTableViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return classes.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let className = classes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell",for: indexPath)
        let classname = cell.viewWithTag(10) as! UILabel
        let numberClass = cell.viewWithTag(11) as! UILabel
    
        classname.text = className.value(forKeyPath: "classes") as? String
        let amt = className.value(forKeyPath: "numberOfAssignments") as? Int
        numberClass.text = String(amt!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "classAssignmentSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AssignmentClassTableViewController{
            let obj = classes[(tableView.indexPathForSelectedRow?.row)!]
            let classname = obj.value(forKeyPath: "classes") as? String
            destination.className = classname
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: "WARNING", message: "Deleting the class will delete all assignments for that class. Are you sure you want to continue?", preferredStyle: .alert)

            let saveAction = UIAlertAction(title: "Yes", style: .default) {
              [unowned self] action in
                let className = self.classes[indexPath.row]
                self.classes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Classes")

                let classTitle = className.value(forKeyPath: "classes") as? String
                request.predicate = NSPredicate(format:"%K == %@","classes",classTitle!)

                let result = try? context.fetch(request)
                let resultData = result as! [NSManagedObject]

                for object in resultData {
                    context.delete(object)
                }
                self.removeInAssignmentTable(name:classTitle!)
                do {
                    try context.save()
                    
                    self.tableView.reloadData()
                } catch {
                    // add general error handle here
                }
            }
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            alert.addAction(saveAction)
            alert.addAction(cancelAction)

            present(alert, animated: true)
        }
    }
    
    func removeInAssignmentTable(name: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignments")
            request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "classType") as? String == name{
                    request.predicate = NSPredicate(format:"%K == %@", "classType", name)

                    let result = try? context.fetch(request)
                    let resultData = result as! [NSManagedObject]

                    for object in resultData {
                        context.delete(object)
                    }
                    do {
                        try context.save()
                    } catch {
                        // add general error handle here
                    }
                }
            }
        } catch {
            print("Failed")
        }
    }
}
    
