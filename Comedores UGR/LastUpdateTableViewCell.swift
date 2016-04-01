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
    
    func configure(date date: NSDate?) {
        var string = NSLocalizedString("Last Update:") + " "
        if let lastUpdate = date {
            let formatter = NSDateFormatter()
            formatter.dateStyle = .ShortStyle
            formatter.timeStyle = .ShortStyle
            formatter.doesRelativeDateFormatting = true
            string += formatter.stringFromDate(lastUpdate)
        } else {
            string += NSLocalizedString("Never")
        }
        label.text = string
    }
}