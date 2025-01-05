//
//  PersistentController.swift
//  MacReader
//
//  Created by Anastasia Ivanova on 05.01.25.
//

import Foundation
import CoreData

class PersistentController {
    /* Class - because classes are reference types, so Core Data stack remains shared across the app.
     
     Classes also support singletones.
     
     A singleton ensures that there is only one instance of the class in your entire app, and all parts of the app use that same instance. By using a singleton, you guarantee there’s only one Core Data stack, and all parts of the app share it.
     
     A singleton is a design pattern that ensures:
         1.    Only one instance of a class is ever created.
         2.    That instance is globally accessible from anywhere in the app.
     
     Step 5: Why Is This a Singleton?

     Now that the PersistentController is complete, let’s review what makes it a singleton:
         1. static let shared:
         This creates a single, globally accessible instance of the class.
         2. class:
         Classes are reference types, so everyone shares the same instance.
         3. One-Time Initialization:
         The init method is called only once when PersistentController.shared is accessed for the first time.
     */
    
    static let shared = PersistentController()
    
    let container: NSPersistentContainer
    
    init(){ // the constructor for the PersistentController class
        container = NSPersistentContainer(name: "MacReaderCoreData")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        container.viewContext
    }
}
