//
//  MR_EmployeeDetailViewController.swift
//  CoreDataExample
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

//DetailViewMode-Type
enum DetailViewModeType: Int {
    case DetailViewModeTypeInsert = 1,
    DetailViewModeTypeUpdate
}

//Constant
let kEntityNameUsers: String = "Users"

class MR_EmployeeDetailViewController: UIViewController {
    
    //IBOutlet
    @IBOutlet weak var textFieldUserId: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    
    //detailViewMode with default Value
    var detailViewModeType:DetailViewModeType = DetailViewModeType.DetailViewModeTypeInsert
    
    //Selected-User
    var selectedUser: Users!
    
    //***********************************************************************
    // MARK: - Init
    //***********************************************************************
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Update Operation
        if detailViewModeType == DetailViewModeType.DetailViewModeTypeUpdate {
            self.textFieldUserId.text = selectedUser.id
            self.textFieldName.text = selectedUser.name
            self.textFieldPhone.text = selectedUser.phone
            self.textFieldUserId.enabled = false
        }else {
            //Insert Operation
            self.textFieldUserId.text = ""
            self.textFieldName.text = ""
            self.textFieldPhone.text = ""
            self.textFieldUserId.enabled = true
        }
    }
    
    //***********************************************************************
    // MARK: - Handle Save Action
    //***********************************************************************
    @IBAction func handleSaveButton(sender: AnyObject) {
        
        //Data Dictionary
        var dataDictionary = Dictionary<String, String>()
        dataDictionary["id"] = self.textFieldUserId.text
        dataDictionary["name"] = self.textFieldName.text
        dataDictionary["phone"] = self.textFieldPhone.text
        
        //Insert Operation
        if detailViewModeType == DetailViewModeType.DetailViewModeTypeInsert {
            //Insert Data into Core-data
            let managedObject: NSManagedObject = CoreDataManager.sharedInstance.insertDataForEntity(kEntityNameUsers, withEntityData: dataDictionary, withManageObjectContext: nil, withInstantUpdate: true)
            //print Log
            managedObject.printNSManagedObjectDescription()
        }else {
            //Update Data into Core-data
            let managedObject: NSManagedObject = CoreDataManager.sharedInstance.updateDataForManagedObject(selectedUser, withEntityData: dataDictionary, withManageObjectContext: nil, withInstantUpdate: true)
            //print Log
            managedObject.printNSManagedObjectDescription()
        }
        
        //POP ViewController
        self.navigationController?.popViewControllerAnimated(true)
    }
}
