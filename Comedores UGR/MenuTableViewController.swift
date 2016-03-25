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
// TODO: Persist data
// TODO: Improve UI
class MenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let fetcher = WeekMenuFetcher()
    var weekMenu = [DayMenu]()
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        
        fetcher.fetchMenu(completionHandler: { menu in
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

