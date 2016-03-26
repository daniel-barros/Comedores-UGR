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
// TODO: Localization
// TODO: Add info and contact screen
// TODO: Highlight today's menu
// TODO: Icon
// TODO: Launch screen
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
            guard weekMenu.isEmpty == false else {
                return
            }
            let archivedMenu = NSKeyedArchiver.archivedDataWithRootObject(weekMenu)
            NSUserDefaults.standardUserDefaults().setObject(archivedMenu, forKey: "weekMenu")
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 150
        
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
        return weekMenu.count
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
        cell.configure(menu: weekMenu[indexPath.row])
        return cell
    }
}

