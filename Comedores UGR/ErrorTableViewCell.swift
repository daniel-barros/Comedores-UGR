//
//  ErrorTableViewCell.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/28/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

class ErrorTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    func configure(error error: FetcherError?) {
        let errorMessage: String
        if let error = error {
            switch error {
            case .NoInternetConnection:
                errorMessage = "No Internet Connection"
            case .Other:
                errorMessage = "Uknown error. Please try again later."
            }
        } else {
            errorMessage = "No data to show. Check again later."
        }
        label.text = NSLocalizedString(errorMessage)
    }
}