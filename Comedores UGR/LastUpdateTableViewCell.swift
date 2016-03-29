//
//  LastUpdateTableViewCell.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/28/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

class LastUpdateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func configure() {
        if let date = NSUserDefaults.standardUserDefaults().objectForKey(DefaultsLastUpdateKey) as? NSDate {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .ShortStyle
            formatter.doesRelativeDateFormatting = true
            label.text = NSLocalizedString("Last Update:") + " " + formatter.stringFromDate(date)
        }
    }
}