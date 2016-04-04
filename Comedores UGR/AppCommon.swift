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
    
    class func customAlternateRedColor() -> UIColor {
        return UIColor(red: 0.996, green: 0.330, blue: 0.287, alpha: 1)
    }
    
    class func customDarkRedColor() -> UIColor {
        return UIColor(red: 0.418, green: 0.043, blue: 0.023, alpha: 1)
    }
}


extension CGSize {
    static var max: CGSize {
        return CGSize(width: CGFloat.max, height: CGFloat.max)
    }
}


#if os(iOS)
extension UIDevice {
    /// - returns: `true` if screen is smaller than iPhone 6
    var isSmalliPhone: Bool {
        let screenSize = UIScreen.mainScreen().bounds
        return min(screenSize.width, screenSize.height) < 375
    }
}
#endif