//
//  ViewController.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/9/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

// TODO: refresh data
// TODO: Watch glance
// TODO: Notification center widget
// TODO: Move to a github repo
// TODO: Persist data
class MenuTableViewController: UITableViewController {
    
    var weekMenu = [DayMenu]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        tableView.contentInset.top = UIApplication.sharedApplication().statusBarFrame.height    // makes room for the status bar
        
        WeekMenuFetcher.fetchMenu(completionHandler: { menu in
            self.weekMenu = menu
            self.tableView.reloadData()
        }, errorHandler: { error in
            // TODO: Handle error
            print(error)
        })
    }
    
    
    // MARK: UITableViewDelegate and UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekMenu[section].dishes.count
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return weekMenu.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DishCell", forIndexPath: indexPath) as! DishTableViewCell
        cell.title.text = weekMenu[indexPath.section].dishes[indexPath.row]
        return cell
    }
    

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return weekMenu[section].date
    }
}

