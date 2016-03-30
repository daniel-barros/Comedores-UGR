//
//  AppCommon.swift
//  Comedores UGR
//
//  Created by Daniel Barros López on 3/27/16.
//  Copyright © 2016 Daniel Barros. All rights reserved.
//

import UIKit

extension UIColor {
    class func customRedColor() -> UIColor {
        return UIColor(red: 0.996, green: 0.230, blue: 0.187, alpha: 1)
    }
}


extension CGSize {
    static var max: CGSize {
        return CGSize(width: CGFloat.max, height: CGFloat.max)
    }
}