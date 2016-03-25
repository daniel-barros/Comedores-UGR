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
// TODO: Improve UI
class MenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let fetcher = WeekMenuFetcher()
    
    var weekMenu: [DayMenu] = {
        if let archivedMenu = NSUserDefaults.standardUserDefaults().dataForKey("weekMenu"),
            menu = NSKeyedUnarchiver.unarchiveObjectWithData(archivedMenu) as? [DayMenu] {
            return menu
        } else {
            return [DayMenu]()
        }
        }() {
        didSet {
            let archivedMenu = NSKeyedArchiver.archivedDataWithRootObject(weekMenu)
            NSUserDefaults.standardUserDefaults().setObject(archivedMenu, forKey: "weekMenu")
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        
        fetcher.fetchMenuAsync(completionHandler: { menu in
            self.weekMenu = menu
            mainQueue {
                self.tableView.reloadData()
            }
        }, errorHandler: { error in
            // TODO: Handle error
            print(error)
        })
    }
    
    
    // MARK: UITableViewDelegate and UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekMenu[section].dishes.count
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return weekMenu.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DishCell", forIndexPath: indexPath) as! DishTableViewCell
        cell.title.text = weekMenu[indexPath.section].dishes[indexPath.row]
        return cell
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return weekMenu[section].date
    }
}

