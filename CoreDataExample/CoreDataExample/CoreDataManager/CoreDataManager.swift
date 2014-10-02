//
//  CoreDataManager.swift
//
//
//  Created by Manish Rathi on 02/10/14.
//  Copyright (c) 2014 Manish Rathi. All rights reserved.
//
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//
//


import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    //***********************************************************************
    // MARK: - Define DB Constant
    //***********************************************************************
    let managedObjectModelName: String = "CoreDataExample"
    let sqliteFileName: String = "CoreDataExample.sqlite"
    
    
    
    //***********************************************************************
    // MARK: - Singleton Instance of CoreDataManager
    //***********************************************************************
    class var sharedInstance: CoreDataManager {
        
    struct staticVars {
        static var onceToken : dispatch_once_t = 0
        static var instance : CoreDataManager? = nil
        }
        dispatch_once(&staticVars.onceToken) {
            staticVars.instance = CoreDataManager()
        }
        return staticVars.instance!
    }
    
    //***********************************************************************
    // MARK: - Core Data stack
    //***********************************************************************
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "Rathi-Inc..PickerViewDemo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(self.managedObjectModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.sqliteFileName)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error in persistentStoreCoordinator \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    //Make it Private as it will be managedObjectContext
    private lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    
    //***********************************************************************
    // MARK: - Default managed-Object Context
    //***********************************************************************
    func defaultManagedObjectContext() -> NSManagedObjectContext {
        return self.managedObjectContext!
    }
    
    func defaultManagedObjectContext(managedObjectContext:NSManagedObjectContext?) -> NSManagedObjectContext {
        var moc = managedObjectContext
        //If nil, use the default managed-Object Context
        if (moc == nil) {
            moc = self.defaultManagedObjectContext()
        }
        return moc!
    }
    
    //***********************************************************************
    // MARK: - Core Data Saving support
    //***********************************************************************
    func saveContext (managedObjectContext: NSManagedObjectContext?) ->Bool {
        var isdataSaved:Bool = true
        //Manage Object Context
        let moc = self.defaultManagedObjectContext(managedObjectContext)
        
        var error: NSError? = nil
        if moc.hasChanges && !moc.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            isdataSaved = false
            NSLog("Unresolved error while Saving \(error), \(error!.userInfo)")
            abort()
        }
        
        return isdataSaved
    }
    
    
    
    //***********************************************************************
    // MARK: - INSERT
    //***********************************************************************
    func insertDataForEntity(entityName:String, withEntityData data:Dictionary<String,AnyObject>, withManageObjectContext managedObjectContext:NSManagedObjectContext?, withInstantUpdate needToSaveNow:Bool) -> NSManagedObject{
        //Manage Object Context
        let moc = self.defaultManagedObjectContext(managedObjectContext)
        //Create empty object
        let managedObject: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: moc) as NSManagedObject
        return self.updateDataForManagedObject(managedObject, withEntityData: data, withManageObjectContext: managedObjectContext, withInstantUpdate: needToSaveNow)
    }
    
    //***********************************************************************
    // MARK: - FETCH
    //***********************************************************************
    func selectDataForEntity(entityName:String, withPredicate predicate:NSPredicate?, withSortDescriptors sortDescriptors:Array<AnyObject>?, withManageObjectContext managedObjectContext:NSManagedObjectContext?) ->Array<AnyObject>?{
        
        // Create fetch request
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.fetchBatchSize = 20
        
        //Manage Object Context
        let moc = self.defaultManagedObjectContext(managedObjectContext)
        
        return moc.executeFetchRequest(fetchRequest, error: nil)
    }
    
    //***********************************************************************
    // MARK: - UPDATE
    //***********************************************************************
    func updateDataForManagedObject(managedObject:NSManagedObject, withEntityData data:Dictionary<String,AnyObject>, withManageObjectContext managedObjectContext:NSManagedObjectContext?, withInstantUpdate needToSaveNow:Bool) -> NSManagedObject{
        //Keys
        let keys = (managedObject.entity.attributesByName as Dictionary).keys
        //Set Values
        for key in keys {
            if let value: AnyObject = data[key as String] {
                managedObject.setValue(value, forKey: key as String)
                //println("\(key) \t \(value)")
            }
        }
        
        //Need to save
        if needToSaveNow {
            //Manage Object Context
            let moc = self.defaultManagedObjectContext(managedObjectContext)
            //save now
            if self.saveContext(moc) {
                println("managedObject data saved")
            }else{
                println("Failed to save to data store")
            }
        }
        return managedObject
    }
    
    //***********************************************************************
    // MARK: - DELETE(All)
    //***********************************************************************
    func deleteManagedObject(managedObject:NSManagedObject?, withManageObjectContext managedObjectContext:NSManagedObjectContext?, withInstantUpdate needToSaveNow:Bool) ->Bool{
        var isdeleted:Bool = true
        //check Object
        if let deletedObject = managedObject {
            //Manage Object Context
            let moc = self.defaultManagedObjectContext(managedObjectContext)
            //delete now
            moc.deleteObject(deletedObject)
            //Need to save
            if needToSaveNow {
                isdeleted = self.saveContext(moc)
            }
        }else {
            println("managedObject is nil,which you are trying to delete")
            isdeleted = false
        }
        
        //Return
        return isdeleted
    }
    
    func deleteAllManagedObjectsFromEntity(entityName:String, withPredicate predicate:NSPredicate?, withManageObjectContext managedObjectContext:NSManagedObjectContext?, withInstantUpdate needToSaveNow:Bool) ->Bool{
        var isdeleted:Bool = true
        
        // Create fetch request
        let fetchRequest: NSFetchRequest = NSFetchRequest()
        //Manage Object Context
        let moc = self.defaultManagedObjectContext(managedObjectContext)
        //Entity
        let entityDescription: NSEntityDescription = NSEntityDescription.entityForName(entityName, inManagedObjectContext: moc)!
        fetchRequest.entity = entityDescription
        // Ignore property values for maximum performance
        fetchRequest.includesPropertyValues = false
        //set predicate
        if let deleteAllPredicate = predicate {
            fetchRequest.predicate = deleteAllPredicate
        }
        
        // Execute the request
        var error: NSError? = nil
        let fetchRequestResults: Array<AnyObject>? = moc.executeFetchRequest(fetchRequest, error: &error)
        //chk nil
        if let fetchResults = fetchRequestResults {
            for managedObject in fetchResults {
                //delete now
                moc.deleteObject(managedObject as NSManagedObject)
            }
        }else {
            println("Couldn't delete managedObjects for entity-name \(entityName)")
            isdeleted = false
        }
        
        //Need to save
        if needToSaveNow {
            isdeleted = self.saveContext(moc)
        }
        
        //Return
        return isdeleted
    }
    
}

