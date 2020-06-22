//
//  Class+CoreDataProperties.swift
//  Planner
//
//  Created by Christina Chau on 6/19/20.
//  Copyright © 2020 Christina Chau. All rights reserved.
//
//

import Foundation
import CoreData


extension Class {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Class> {
        return NSFetchRequest<Class>(entityName: "Class")
    }

    @NSManaged public var classes: String?
    
}
