//
//  MR_EmployeeListViewController.swift
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

class MR_EmployeeListViewController: UITableViewController {
    
    //Property
    private var userList: Array <AnyObject> = Array()
    
    //***********************************************************************
    // MARK: - Init
    //***********************************************************************
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Refresh UserList
        self.refreshUserList()
    }
    
    func refreshUserList() {
        //Fetch User List
        self.userList =  CoreDataManager.sharedInstance.selectDataForEntity(kEntityNameUsers, withPredicate: nil, withSortDescriptors: nil, withManageObjectContext: nil)!
        //reload Table
        self.tableView.reloadData()
    }
    
    //***********************************************************************
    // MARK: - UITableViewDataSource
    //***********************************************************************
    
    //numberOfRowsInSection
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userList.count
    }
    
    //cellForRowAtIndexPath
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell : MR_EmployeeTableViewCell=tableView.dequeueReusableCellWithIdentifier("MR_EmployeeTableViewCell", forIndexPath: indexPath) as MR_EmployeeTableViewCell
        
        //Configure the cell...
        cell.labelUserId.text = (userList[indexPath.row] as Users).id
        cell.labelName.text = (userList[indexPath.row] as Users).name
        cell.labelPhone.text = (userList[indexPath.row] as Users).phone
        
        return cell
    }
    
    
    //didSelectRowAtIndexPath
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedUser:Users = userList[indexPath.row] as Users
        self.performSegueWithIdentifier("PUSH_UpdateUserDetailSegue", sender: selectedUser)
    }
    
    //Swipe to Delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let deletedUser:Users = userList[indexPath.row] as Users
            CoreDataManager.sharedInstance.deleteManagedObject(deletedUser, withManageObjectContext: nil, withInstantUpdate: true)
            //Refresh UserList
            self.refreshUserList()
        }
    }
    
    //***********************************************************************
    // MARK: - UITableViewDataSource
    //***********************************************************************
    @IBAction func handleAddButton(sender: AnyObject) {
        //perform Segue
        self.performSegueWithIdentifier("PUSH_InsertUserDetailSegue", sender: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PUSH_InsertUserDetailSegue" {
            let detailViewController : MR_EmployeeDetailViewController = segue.destinationViewController as MR_EmployeeDetailViewController
            detailViewController.detailViewModeType = DetailViewModeType.DetailViewModeTypeInsert
        }else if segue.identifier == "PUSH_UpdateUserDetailSegue" {
            let detailViewController : MR_EmployeeDetailViewController = segue.destinationViewController as MR_EmployeeDetailViewController
            detailViewController.selectedUser = sender as Users
            detailViewController.detailViewModeType = DetailViewModeType.DetailViewModeTypeUpdate
        }
    }
}